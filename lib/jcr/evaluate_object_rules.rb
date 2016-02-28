# Copyright (c) 2015 American Registry for Internet Numbers
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

  def self.evaluate_object_rule jcr, rule_atom, data, econs, behavior = nil

    push_trace_stack( econs, jcr )
    trace( econs, "Evaluating object rule starting at #{slice_to_s(jcr)} against", data )
    retval = evaluate_object( jcr, rule_atom, data, econs, behavior )
    trace_eval( econs, "Object", retval )
    pop_trace_stack( econs )
    return retval

  end

  def self.evaluate_object jcr, rule_atom, data, econs, behavior = nil

    rules, annotations = get_rules_and_annotations( jcr )

    # if the data is not an object (Hash)
    return evaluate_reject( annotations,
      Evaluation.new( false, "#{data} is not an object for #{raised_rule(jcr,rule_atom)}"), econs ) unless data.is_a? Hash

    # if the object has no members and there are zero sub-rules (it is suppose to be empty)
    return evaluate_reject( annotations,
      Evaluation.new( true, nil ), econs ) if rules.empty? && data.length == 0

    # if the object has members and there are zero sub-rules (it is suppose to be empty)
    return evaluate_reject( annotations,
      Evaluation.new( false, "Non-empty object for #{raised_rule(jcr,rule_atom)}" ), econs ) if rules.empty? && data.length != 0

    retval = nil
    behavior = ObjectBehavior.new unless behavior

    rules.each do |rule|

      # short circuit logic
      if rule[:choice_combiner] && retval && retval.success
        next
      elsif rule[:sequence_combiner] && retval && !retval.success
        return evaluate_reject( annotations, retval, econs ) # short circuit
      end

      repeat_min, repeat_max = get_repetitions( rule, econs )

      # Pay attention here:
      # Group rules need to be treated differently than other rules
      # Groups must be evaluated as if they are rules evaluated in
      # isolation until they evaluate as true.
      # Also, groups must be handed the entire object, not key/values
      # as member rules use.

      if (grule = get_group(rule, econs))

        successes = 0
        for i in 0..repeat_max
          group_behavior = ObjectBehavior.new
          e = evaluate_rule( grule, rule_atom, data, econs, group_behavior )
          if e.success
            behavior.checked_hash.merge!( group_behavior.checked_hash )
            successes = successes + 1
          else
            break;
          end
        end

        if successes == 0 && repeat_min > 0
          retval = Evaluation.new( false, "object does not contain group #{rule} for #{raised_rule(jcr,rule_atom)}")
        elsif successes < repeat_min
          retval = Evaluation.new( false, "object does not have contain necessary number of group #{rule} for #{raised_rule(jcr,rule_atom)}")
        else
          retval = Evaluation.new( true, nil )
        end

      else # if not grule

        repeat_results = nil

        # do a little lookahead for member rules defined by names
        # if defined by a name, and not a regex, just pluck it from the object
        # and short-circuit the enumeration

        lookahead = get_leaf_rule( rule, econs )
        lrules, lannotations = get_rules_and_annotations( lookahead[:member_rule] )
        if lrules[0][:member_name]

          repeat_results = {}
          k = lrules[0][:member_name][:q_string].to_s
          v = data[k]
          if v
            unless behavior.checked_hash[k]
              e = evaluate_rule(rule, rule_atom, [k, v], econs, nil)
              behavior.checked_hash[k] = e.success
              repeat_results[ k ] = v if e.success
            end
          else
            trace( econs, "No member '#{k}' found in object.")
          end

        else

          trace( econs, "Scanning object.")
          repeat_results = data.select do |k,v|
            unless behavior.checked_hash[k]
              e = evaluate_rule(rule, rule_atom, [k, v], econs, nil)
              behavior.checked_hash[k] = e.success
              e.success
            end
          end

        end

        trace( econs, "Found #{repeat_results.length} matching members repetitions in object with min #{repeat_min} and max #{repeat_max}" )
        if repeat_results.length == 0 && repeat_min > 0
          retval = Evaluation.new( false, "object does not contain #{rule} for #{raised_rule(jcr,rule_atom)}")
        elsif repeat_results.length < repeat_min
          retval = Evaluation.new( false, "object does not have enough #{rule} for #{raised_rule(jcr,rule_atom)}")
        elsif repeat_results.length > repeat_max
          retval = Evaluation.new( false, "object has too many #{rule} for #{raised_rule(jcr,rule_atom)}")
        else
          retval = Evaluation.new( true, nil)
        end
      end

    end # end if grule else

    return evaluate_reject( annotations, retval, econs )
  end

  def self.object_to_s( jcr, shallow=true )
    rules, annotations = get_rules_and_annotations( jcr )
    return "#{annotations_to_s( annotations)} { ... }"
  end
end
