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

  def self.evaluate_array_rule jcr, rule_atom, data, mapping

    rules, annotations = get_rules_and_annotations( jcr )

    ordered = true
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
      return evaluate_reject( annotations, evaluate_array_rule_ordered( rules, rule_atom, data, mapping ) )
    else
      return evaluate_reject( annotations, evaluate_array_rule_unordered( rules, rule_atom, data, mapping ) )
    end
  end

  def self.evaluate_array_rule_ordered jcr, rule_atom, data, mapping
    retval = nil
    array_index = 0

    jcr.each do |rule|

      # short circuit logic
      if rule[:choice_combiner] && retval && retval.success
        return retval # short circuit
      elsif rule[:sequence_combiner] && retval && !retval.success
        return retval # short circuit
      end

      repeat_min, repeat_max = get_repetitions( rule )

      min_evals = 0
      if repeat_min == 0
        retval = Evaluation.new( true, nil )
      else
        for i in 1..repeat_min do
          if array_index == data.length
            return Evaluation.new( false, "array is not large enough for #{jcr} from #{rule_atom}" )
          else
            retval = evaluate_rule( rule, rule_atom, data[ array_index ], mapping )
            break unless retval.success
            array_index = array_index + 1
            min_evals = i
          end
        end
      end
      if !retval || retval.success
        for i in min_evals..repeat_max-1 do
          break if array_index == data.length
          e = evaluate_rule( rule, rule_atom, data[ array_index ], mapping )
          break unless e.success
          array_index = array_index + 1
        end
      end

    end

    if data.length > array_index
      retval = Evaluation.new( false, "More itmes in array than specified for #{jcr} from #{rule_atom}" )
    end

    return retval
  end

  def self.evaluate_array_rule_unordered jcr, rule_atom, data, mapping

    retval = nil
    checked = []

    jcr.each do |rule|

      # short circuit logic
      if rule[:choice_combiner] && retval && retval.success
        return retval # short circuit
      elsif rule[:sequence_combiner] && retval && !retval.success
        return retval # short circuit
      end

      repeat_min, repeat_max = get_repetitions( rule )

      i = 0
      results = data.select do |v|
        success = false
        unless checked[ i ]
          e = evaluate_rule( rule, rule_atom, v, mapping)
          checked[ i ] = e.success
          success = e.success
        end
        i = i + 1
        success
      end

      if results.length == 0 && repeat_min > 0
        retval = Evaluation.new( false, "array does not contain #{rule} for #{jcr} from #{rule_atom}")
      elsif results.length < repeat_min
        retval = Evaluation.new( false, "array does not have enough #{rule} for #{jcr} from #{rule_atom}")
      elsif results.length > repeat_max
        retval = Evaluation.new( false, "array has too many #{rule} for #{jcr} from #{rule_atom}")
      else
        retval = Evaluation.new( true, nil)
      end

    end

    return retval
  end

end
