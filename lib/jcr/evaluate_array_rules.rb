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

require 'ipaddr'
require 'time'
require 'addressable/uri'
require 'addressable/template'
require 'email_address_validator'
require 'big-phoney'

require 'jcr/parser'
require 'jcr/map_rule_names'
require 'jcr/check_groups'
require 'jcr/evaluate_rules'

module JCR

  class ArrayBehavior
    attr_accessor :checked_hash, :last_index, :ordered, :extra_prohibited

    def initialize( current_behavior = nil )
      if current_behavior
        @checked_hash = {}
        @checked_hash.merge!( current_behavior.checked_hash )
        @last_index = current_behavior.last_index
        @ordered = current_behavior.ordered
        @extra_prohibited = false
      else
        @checked_hash = {}
        @last_index = 0
        @ordered = true
        @extra_prohibited = true
      end
    end
  end

  def self.evaluate_array_rule jcr, rule_atom, data, mapping, behavior = nil

    rules, annotations = get_rules_and_annotations( jcr )

    ordered = true

    if behavior && behavior.is_a?( ArrayBehavior )
      ordered = behavior.ordered
    end

    annotations.each do |a|
      if a[:unordered_annotation]
        ordered = false
        break
      end
    end

    # if the data is not an array
    return evaluate_reject( annotations,
      Evaluation.new( false, "#{data} is not an array at #{jcr} from #{rule_atom}") ) unless data.is_a? Array

    # if the array is zero length and there are zero sub-rules (it is suppose to be empty)
    return evaluate_reject( annotations,
      Evaluation.new( true, nil ) ) if rules.empty? && data.empty?

    # if the array is not empty and there are zero sub-rules (it is suppose to be empty)
    return evaluate_reject( annotations,
      Evaluation.new( false, "Non-empty array at #{jcr} from #{rule_atom}" ) ) if rules.empty? && data.length != 0

    if ordered
      return evaluate_reject( annotations, evaluate_array_rule_ordered( rules, rule_atom, data, mapping, behavior ) )
    else
      return evaluate_reject( annotations, evaluate_array_rule_unordered( rules, rule_atom, data, mapping, behavior ) )
    end
  end

  def self.evaluate_array_rule_ordered jcr, rule_atom, data, mapping, behavior = nil
    retval = nil

    behavior = ArrayBehavior.new unless behavior
    array_index = behavior.last_index


    jcr.each do |rule|

      # short circuit logic
      if rule[:choice_combiner] && retval && retval.success
        break
      elsif rule[:sequence_combiner] && retval && !retval.success
        break
      end

      repeat_min, repeat_max = get_repetitions( rule )

      # group rules must be evaluated differently
      # groups require the effects of the evaluation to be discarded if they are false
      # groups must also be given the entire array

      if (grule = get_group(rule, mapping))

        if repeat_min == 0
          retval = Evaluation.new( true, nil )
        else
          for i in 1..repeat_min do
            if array_index == data.length
              return Evaluation.new( false, "array is not large enough for #{jcr} from #{rule_atom}" )
            else
              group_behavior = ArrayBehavior.new( behavior )
              group_behavior.last_index = array_index
              retval = evaluate_array_rule( grule, rule_atom, data, mapping, group_behavior )
              if retval.success
                behavior.checked_hash.merge!( group_behavior.checked_hash )
                array_index = group_behavior.last_index
              else
                break;
              end
            end
          end
        end
        if !retval || retval.success
          for i in behavior.checked_hash.length..repeat_max-1 do
            break if array_index == data.length
            group_behavior = ArrayBehavior.new( behavior )
            group_behavior.last_index = array_index
            e = evaluate_array_rule( grule, rule_atom, data, mapping, group_behavior )
            if e.success
              behavior.checked_hash.merge!( group_behavior.checked_hash )
              array_index = group_behavior.last_index
            else
              break;
            end
          end
        end

      else # else not grule (group)

        if repeat_min == 0
          retval = Evaluation.new( true, nil )
        else
          for i in 1..repeat_min do
            if array_index == data.length
              return Evaluation.new( false, "array is not large enough for #{jcr} from #{rule_atom}" )
            else
              retval = evaluate_rule( rule, rule_atom, data[ array_index ], mapping, nil )
              break unless retval.success
              array_index = array_index + 1
              behavior.checked_hash[ i + behavior.last_index ] = retval.success
            end
          end
        end
        if !retval || retval.success
          for i in behavior.checked_hash.length..repeat_max-1 do
            break if array_index == data.length
            e = evaluate_rule( rule, rule_atom, data[ array_index ], mapping, nil )
            break unless e.success
            array_index = array_index + 1
          end
        end

      end # end if grule else

    end

    behavior.last_index = array_index

    if data.length > array_index && behavior.extra_prohibited
      retval = Evaluation.new( false, "More itmes in array than specified for #{jcr} from #{rule_atom}" )
    end

    return retval

  end

  def self.evaluate_array_rule_unordered jcr, rule_atom, data, mapping, behavior = nil

    retval = nil
    unless behavior
      behavior = ArrayBehavior.new
      behavior.ordered = false
    end
    highest_index = 0

    jcr.each do |rule|

      # short circuit logic
      if rule[:choice_combiner] && retval && retval.success
        break
      elsif rule[:sequence_combiner] && retval && !retval.success
        break
      end

      repeat_min, repeat_max = get_repetitions( rule )

      # group rules must be evaluated differently
      # groups require the effects of the evaluation to be discarded if they are false
      # groups must also be given the entire array

      if (grule = get_group(rule, mapping))

        successes = 0
        for i in 0..repeat_max-1
          group_behavior = ArrayBehavior.new( behavior )
          group_behavior.last_index = highest_index
          group_behavior.ordered = false
          e = evaluate_array_rule( grule, rule_atom, data, mapping, group_behavior )
          if e.success
            highest_index = group_behavior.last_index
            behavior.checked_hash.merge!( group_behavior.checked_hash )
            successes = successes + 1
          else
            break;
          end
        end

        if successes == 0 && repeat_min > 0
          retval = Evaluation.new( false, "array does not contain #{rule} for #{jcr} from #{rule_atom}")
        elsif successes < repeat_min
          retval = Evaluation.new( false, "array does not have enough #{rule} for #{jcr} from #{rule_atom}")
        elsif successes > repeat_max
          retval = Evaluation.new( false, "array has too many #{rule} for #{jcr} from #{rule_atom}")
        else
          retval = Evaluation.new( true, nil )
        end

      else # else not group rule

        successes = 0
        for i in behavior.last_index..data.length
          break if successes == repeat_max
          unless behavior.checked_hash[ i ]
            e = evaluate_rule( rule, rule_atom, data[ i ], mapping, nil )
            if e.success
              behavior.checked_hash[ i ] = e.success
              highest_index = i if i > highest_index
              successes = successes + 1
            end
          end
        end

        if successes == 0 && repeat_min > 0
          retval = Evaluation.new( false, "array does not contain #{rule} for #{jcr} from #{rule_atom}")
        elsif successes < repeat_min
          retval = Evaluation.new( false, "array does not have enough #{rule} for #{jcr} from #{rule_atom}")
        elsif successes > repeat_max
          retval = Evaluation.new( false, "array has too many #{rule} for #{jcr} from #{rule_atom}")
        else
          retval = Evaluation.new( true, nil)
        end

      end # if grule else

    end

    behavior.last_index = highest_index

    if data.length > behavior.checked_hash.length && behavior.extra_prohibited
      retval = Evaluation.new( false, "More itmes in array than specified for #{jcr} from #{rule_atom}" )
    end

    return retval
  end

end
