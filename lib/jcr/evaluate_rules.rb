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
require 'jcr/evaluate_array_rules'
require 'jcr/evaluate_group_rules'
require 'jcr/evaluate_member_rules'
require 'jcr/evaluate_value_rules'

module JCR

  class Evaluation
    attr_accessor :success, :reason, :child_evaluation
    def initialize success, reason
      @success = success
      @reason = reason
    end
  end

  def self.evaluate_rule jcr, rule_atom, data, mapping
    case
      when jcr[:rule]
        return evaluate_rule( jcr[:rule], rule_atom, data, mapping)
      when jcr[:target_rule_name]
        target = mapping[ jcr[:target_rule_name][:rule_name].to_s ]
        raise "Target rule not in mapping. This should have been checked earlier." unless target
        return evaluate_rule( target, target, data, mapping )
      when jcr[:primitive_rule]
        return evaluate_value_rule( jcr[:primitive_rule], rule_atom, data, mapping)
      when jcr[:group_rule]
        return evaluate_group_rule( jcr[:group_rule], rule_atom, data, mapping)
      when jcr[:array_rule]
        return evaluate_array_rule( jcr[:array_rule], rule_atom, data, mapping)
      when jcr[:object_rule]
        return evaluate_object_rule( jcr[:object_rule], rule_atom, data, mapping)
      when jcr[:member_rule]
        return evaluate_member_rule( jcr[:member_rule], rule_atom, data, mapping)
      else
        return Evaluation.new( true, nil )
    end
  end

  def self.get_repetitions rule

    repeat_min = 1
    repeat_max = 1
    if rule[:optional]
      repeat_min = 0
      repeat_max = 1
    elsif rule[:one_or_more]
      repeat_min = 1
      repeat_max = Float::INFINITY
    elsif rule[:specific_repetition] && rule[:specific_repetition].is_a?( Parslet::Slice )
      repeat_min = repeat_max = rule[:specific_repetition].to_s.to_i
    else
      o = rule[:repetition_interval]
      if o
        repeat_min = 0
        repeat_max = Float::INFINITY
      end
      o = rule[:repetition_min]
      if o
        if o.is_a?( Parslet::Slice )
          repeat_min = o.to_s.to_i
        end
      end
      o = rule[:repetition_max]
      if o
        if o.is_a?( Parslet::Slice )
          repeat_max = o.to_s.to_i
        end
      end
    end

    return repeat_min, repeat_max
  end

  def self.get_rules_and_annotations jcr
    rules = []
    annotations = []

    if jcr.is_a?( Hash )
      jcr = [ jcr ]
    end

    if jcr.is_a? Array
      i = 0
      jcr.each do |sub|
        case
          when sub[:unordered_annotation]
            annotations << sub
            i = i + 1
          when sub[:reject_annotation]
            annotations << sub
            i = i + 1
          when sub[:root_annotation]
            annotations << sub
            i = i + 1
          when sub[:primitive_rule],sub[:object_rule],sub[:group_rule],sub[:array_rule],sub[:target_rule_name]
            break
        end
      end
      rules = jcr[i,jcr.length]
    end

    return rules, annotations
  end

  def self.evaluate_reject annotations, evaluation

    reject = false
    annotations.each do |a|
      if a[:reject_annotation]
        reject = true
        break
      end
    end

    if reject
      evaluation.success = !evaluation.success
    end
    return evaluation
  end
end
