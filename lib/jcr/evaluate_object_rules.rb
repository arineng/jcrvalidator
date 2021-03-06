# Copyright (c) 2015-2016 American Registry for Internet Numbers
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
# IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

require 'jcr/parser'
require 'jcr/map_rule_names'
require 'jcr/check_groups'
require 'jcr/evaluate_rules'

module JCR

  class ObjectBehavior
    attr_accessor :checked_hash

    def initialize
      @checked_hash = {}
    end
  end

  def self.evaluate_object_rule jcr, rule_atom, data, econs, behavior = nil, target_annotations = nil

    push_trace_stack( econs, jcr )
    if behavior
      trace( econs, "Evaluating group in object rule starting at #{slice_to_s(jcr)} against", data )
      trace_def( econs, "object group", jcr, data )
    else
      trace( econs, "Evaluating object rule starting at #{slice_to_s(jcr)} against", data )
      trace_def( econs, "object", jcr, data )
    end
    retval = evaluate_object( jcr, rule_atom, data, econs, behavior, target_annotations )
    if behavior
      trace_eval( econs, "Object group", retval, jcr, data, "object" )
    else
      trace_eval( econs, "Object", retval, jcr, data, "object" )
    end
    pop_trace_stack( econs )
    return retval

  end

  def self.evaluate_object jcr, rule_atom, data, econs, behavior = nil, target_annotations = nil

    rules, annotations = get_rules_and_annotations( jcr )

    # if the data is not an object (Hash)
    return evaluate_not( annotations,
      Evaluation.new( false, "#{data} is not an object for #{raised_rule(jcr,rule_atom)}"),
                      econs, target_annotations ) unless data.is_a? Hash

    # if the object has no members and there are zero sub-rules (it is suppose to be empty)
    return evaluate_not( annotations,
      Evaluation.new( true, nil ), econs, target_annotations ) if rules.empty? && data.length == 0

    # if the object has members and there are zero sub-rules (it is suppose to be empty)
    return evaluate_not( annotations,
      Evaluation.new( false, "Non-empty object for #{raised_rule(jcr,rule_atom)}" ),
                         econs, target_annotations ) if rules.empty? && data.length != 0

    retval = nil
    behavior = ObjectBehavior.new unless behavior

    rules.each do |rule|

      # short circuit logic
      if rule[:choice_combiner] && retval && retval.success
        next
      elsif rule[:sequence_combiner] && retval && !retval.success
        return evaluate_not( annotations, retval, econs, target_annotations ) # short circuit
      end

      repeat_min, repeat_max, repeat_step = get_repetitions( rule, econs )

      # Pay attention here:
      # Group rules need to be treated differently than other rules
      # Groups must be evaluated as if they are rules evaluated in
      # isolation until they evaluate as true.
      # Also, groups must be handed the entire object, not key/values
      # as member rules use.

      grule,gtarget_annotations = get_group(rule, econs)
      if grule

        successes = 0
        for i in 0..repeat_max-1
          group_behavior = ObjectBehavior.new
          group_behavior.checked_hash.merge!( behavior.checked_hash )
          e = evaluate_rule( grule, rule_atom, data, econs, group_behavior, gtarget_annotations )
          if e.success
            behavior.checked_hash.merge!( group_behavior.checked_hash )
            successes = successes + 1
          else
            break;
          end
        end

        if successes == 0 && repeat_min > 0
          retval = Evaluation.new( false, "object does not contain group #{jcr_to_s(rule)} for #{raised_rule(jcr,rule_atom)}")
        elsif successes < repeat_min
          retval = Evaluation.new( false, "object does not have contain necessary number of group #{jcr_to_s(rule)} for #{raised_rule(jcr,rule_atom)}")
        elsif repeat_step && ( successes - repeat_min ) % repeat_step != 0
          retval = Evaluation.new( false, "object matches (#{successes}) do not have contain repetition #{repeat_max} % #{repeat_step} of group #{jcr_to_s(rule)} for #{raised_rule(jcr,rule_atom)}")
        else
          retval = Evaluation.new( true, nil )
        end

      else # if not grule

        repeat_results = nil
        member_found = false

        # do a little lookahead for member rules defined by names
        # if defined by a name, and not a regex, just pluck it from the object
        # and short-circuit the enumeration

        lookahead, ltarget_annotations = get_leaf_rule( rule, econs )
        lrules, lannotations = get_rules_and_annotations( lookahead[:member_rule] )
        if lrules[0][:member_name]

          repeat_results = {}
          k = lrules[0][:member_name][:q_string].to_s
          v = data[k]
          if v
            unless behavior.checked_hash[k]
              e = evaluate_rule(rule, rule_atom, [k, v], econs, nil, nil)
              behavior.checked_hash[k] = e.success
              member_found = true if e.member_found
              repeat_results[ k ] = v if e.success
            end
          else
            trace( econs, "No member '#{k}' found in object.")
            e = evaluate_rule(rule, rule_atom, [nil, nil], econs, nil, nil)
            repeat_results[ nil ] = nil if e.success
          end

        else

          regex = lrules[0][:member_regex][:regex]
          trace( econs, "Scanning object for #{regex}.")
          i = 0
          found = false
          repeat_results = data.select do |k,v|
            unless behavior.checked_hash[k]
              if i < repeat_max
                e = evaluate_rule(rule, rule_atom, [k, v], econs, nil, nil)
                behavior.checked_hash[k] = e.success
                i = i + 1 if e.success
                found = true if e.member_found
                member_found = true if e.member_found
                e.success
              end
            end
          end
          unless found
            trace( econs, "No member matching #{regex} found in object.")
            e = evaluate_rule(rule, rule_atom, [nil, nil], econs, nil, nil)
            repeat_results[ nil ] = nil if e.success
          end

        end

        trace( econs, "Found #{repeat_results.length} matching members repetitions in object with min #{repeat_min} and max #{repeat_max}" )
        if repeat_results.length == 0 && repeat_min > 0
          retval = Evaluation.new( false, "object does not contain #{jcr_to_s(rule)} for #{raised_rule(jcr,rule_atom)}")
        elsif repeat_results.length < repeat_min
          retval = Evaluation.new( false, "object does not have enough #{jcr_to_s(rule)} for #{raised_rule(jcr,rule_atom)}")
        elsif repeat_results.length > repeat_max
          retval = Evaluation.new( false, "object has too many #{jcr_to_s(rule)} for #{raised_rule(jcr,rule_atom)}")
        elsif repeat_step && ( repeat_results.length - repeat_min ) % repeat_step != 0
          retval = Evaluation.new( false, "object matches (#{repeat_results.length}) does not match repetition step of #{repeat_max} & #{repeat_step} for #{jcr_to_s(rule)} for #{raised_rule(jcr,rule_atom)}")
        elsif member_found && repeat_results.length == 0 && repeat_max > 0
          retval = Evaluation.new( false, "object contains #{jcr_to_s(rule)} with member name though incorrect value for #{raised_rule(jcr,rule_atom)}")
        else
          retval = Evaluation.new( true, nil)
        end
      end

    end # end if grule else

    return evaluate_not( annotations, retval, econs, target_annotations )
  end

  def self.object_to_s( jcr, shallow=true )
    rules, annotations = get_rules_and_annotations( jcr )
    return "#{annotations_to_s( annotations)}{ #{rules_to_s(rules,shallow)} }"
  end
end
