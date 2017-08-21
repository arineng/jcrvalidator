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

require 'ipaddr'
require 'time'
require 'pp'
require 'addressable/uri'
require 'addressable/template'
require 'email_address_validator'
require 'big-phoney'
require 'json'

require 'jcr/parser'
require 'jcr/map_rule_names'
require 'jcr/check_groups'
require 'jcr/evaluate_array_rules'
require 'jcr/evaluate_object_rules'
require 'jcr/evaluate_group_rules'
require 'jcr/evaluate_member_rules'
require 'jcr/evaluate_value_rules'


# Adapted from Matt Sears
class Proc
  def jcr_callback(callable, *args)
    self === Class.new do
      method_name = callable.to_sym
      define_method(method_name) { |&block| block.nil? ? true : block.call(*args) }
      define_method("#{method_name}?") { true }
      def method_missing(method_name, *args, &block) false; end
    end.new
  end
end

module JCR

  class Evaluation
    attr_accessor :success, :reason, :member_found
    def initialize success, reason
      @success = success
      @reason = reason
    end
  end

  class EvalConditions
    attr_accessor :mapping, :callbacks, :trace, :trace_stack, :first_failure
    def initialize mapping, callbacks, trace = false
      @first_failure = nil
      @mapping = mapping
      @trace = trace
      @trace_stack = []
      if callbacks
        @callbacks = callbacks
      else
        @callbacks = {}
      end
    end
  end

  def self.evaluate_rule jcr, rule_atom, data, econs, behavior = nil
    if jcr.is_a?( Hash )
      if jcr[:rule_name]
        rn = slice_to_s( jcr[:rule_name] )
        trace( econs, "Named Rule: #{rn}" )
      end
    end

    retval = Evaluation.new( false, "failed to evaluate rule properly" )
    case
      when behavior.is_a?( ArrayBehavior )
        retval = evaluate_array_rule( jcr, rule_atom, data, econs, behavior)
      when behavior.is_a?( ObjectBehavior )
        retval = evaluate_object_rule( jcr, rule_atom, data, econs, behavior)
      when jcr[:rule]
        retval = evaluate_rule( jcr[:rule], rule_atom, data, econs, behavior)
      when jcr[:target_rule_name]
        target = econs.mapping[ jcr[:target_rule_name][:rule_name].to_s ]
        raise "Target rule not in mapping. This should have been checked earlier." unless target
        trace( econs, "Referencing target rule #{slice_to_s(target)} from #{slice_to_s( jcr[:target_rule_name][:rule_name] )}" )
        retval = evaluate_rule( target, target, data, econs, behavior )
      when jcr[:primitive_rule]
        retval = evaluate_value_rule( jcr[:primitive_rule], rule_atom, data, econs)
      when jcr[:group_rule]
        retval = evaluate_group_rule( jcr[:group_rule], rule_atom, data, econs, behavior)
      when jcr[:array_rule]
        retval = evaluate_array_rule( jcr[:array_rule], rule_atom, data, econs, behavior)
      when jcr[:object_rule]
        retval = evaluate_object_rule( jcr[:object_rule], rule_atom, data, econs, behavior)
      when jcr[:member_rule]
        retval = evaluate_member_rule( jcr[:member_rule], rule_atom, data, econs)
      else
        retval = Evaluation.new( true, nil )
    end
    if jcr.is_a?( Hash ) && jcr[:rule_name]
      rn = jcr[:rule_name].to_s
      if econs.callbacks[ rn ]
        retval = evaluate_callback( jcr, data, econs, rn, retval )
      end
    end
    return retval
  end

  def self.evaluate_callback jcr, data, econs, callback, e
    retval = e
    c = econs.callbacks[ callback ]
    if e.success
      retval = c.jcr_callback :rule_eval_true, jcr, data
    else
      retval = c.jcr_callback :rule_eval_false, jcr, data, e
    end
    if retval.is_a? TrueClass
      retval = Evaluation.new( true, nil )
    elsif retval.is_a? FalseClass
      retval = Evaluation.new( false, nil )
    elsif retval.is_a? String
      retval = Evaluation.new( false, retval )
    end
    trace( econs, "Callback #{callback} given evaluation of #{e.success} and returned #{retval}")
    return retval
  end

  def self.get_repetitions rule, econs

    repeat_min = 1
    repeat_max = 1
    repeat_step = nil
    if rule[:optional]
      repeat_min = 0
      repeat_max = 1
    elsif rule[:one_or_more]
      repeat_min = 1
      repeat_max = Float::INFINITY
      if rule[:repetition_step]
        repeat_step = rule[:repetition_step].to_s.to_i
        repeat_min = repeat_step
      end
    elsif rule[:zero_or_more]
      repeat_min = 0
      repeat_max = Float::INFINITY
      repeat_step = rule[:repetition_step].to_s.to_i if rule[:repetition_step]
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
      o = rule[:repetition_step]
      if o
        if o.is_a?( Parslet::Slice )
          repeat_step = o.to_s.to_i
        end
      end
    end

    trace( econs, "rule repetition min = #{repeat_min} max = #{repeat_max} repetition step = #{repeat_step}" )
    return repeat_min, repeat_max, repeat_step
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
          when sub[:not_annotation]
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

  def self.merge_rules rules
    new_rule = Hash.new
    rules.each do |rule|
      new_rule.merge!(rule) do |key,oldval,newval|
        raise "error: conflict in merge of #{rule} with #{new_rule}"
      end
    end
    return new_rule
  end

  def self.evaluate_not annotations, evaluation, econs
    is_not = false
    annotations.each do |a|
      if a[:not_annotation]
        is_not = true
        break
      end
    end

    if is_not
      trace( econs, "Not annotation changing result from #{evaluation.success} to #{!evaluation.success}")
      evaluation.success = !evaluation.success
    end
    return evaluation
  end

  def self.get_group rule, econs
    return rule[:group_rule] if rule[:group_rule]
    #else
    if rule[:target_rule_name]
      target = econs.mapping[ rule[:target_rule_name][:rule_name].to_s ]
      raise "Target rule not in mapping. This should have been checked earlier." unless target
      trace( econs, "Referencing target rule #{slice_to_s(target)} from #{slice_to_s( rule[:target_rule_name][:rule_name] )}" )
      return get_group( target, econs )
    end
    #else
    return false
  end

  def self.get_leaf_rule rule, econs
    if rule[:target_rule_name ]
      target = econs.mapping[ rule[:target_rule_name][:rule_name].to_s ]
      raise "Target rule not in mapping. This should have been checked earlier." unless target
      trace( econs, "Referencing target rule #{slice_to_s(target)} from #{slice_to_s( rule[:target_rule_name][:rule_name] )}" )
      return target
    end
    #else
    return rule
  end

  def self.push_trace_stack econs, jcr
    econs.trace_stack.push( find_first_slice( jcr ) )
  end

  def self.pop_trace_stack econs
    econs.trace_stack.pop
  end

  def self.elide s
    if s.length > 60
      s = s[0..56]
      s = s + " ..."
    end
    return s
  end

  def self.trace econs, message, data = nil
    if econs.trace
      if data
        if data.is_a? String
          s = '"' + data + '"'
        else
          s = data.pretty_print_inspect
        end
        message = "#{message} data: #{elide(s)}"
      end
      last = econs.trace_stack.last
      pos = "#{last.line_and_column}@#{last.offset}" if last
      puts "[ #{econs.trace_stack.length}:#{pos} ] #{message}"
    end
  end

  def self.trace_def econs, type, jcr, data
    if econs.trace
      s = ""
      case type
        when "value"
          s = elide( value_to_s( jcr ) )
        when "member"
          s = elide( member_to_s( jcr  ) )
        when "object"
          s = elide( object_to_s( jcr ) )
        when "array"
          s = elide( array_to_s( jcr ) )
        when "group"
          s = elide( group_to_s( jcr ) )
        else
          s = "** unknown rule **"
      end
      trace( econs, "#{type} definition: #{s}", data)
    end
  end

  def self.trace_eval econs, message, evaluation, jcr, data, type
    if evaluation.success
      trace( econs, "#{message} evaluation is true" )
    else
      trace( econs, "#{message} evaluation failed: #{evaluation.reason}")
      unless econs.first_failure
        econs.first_failure = evaluation
        trace( econs, "** LIKELY ROOT CAUSE FOR FAILURE **" )
        trace( econs, "***********************************" )
        rule = find_first_slice( jcr )
        pos = "Failed rule at line,column: #{rule.line_and_column} file position offset: #{rule.offset}"
        trace( econs, pos )
        trace_def( econs, type, jcr, data )
        data_s = "JSON that failed to validate: #{data.to_json}"
        trace( econs, data_s )
        trace( econs, "***********************************" )
      end
    end
  end

  def self.find_first_slice slice
    if slice.is_a? Parslet::Slice
      return slice
    elsif slice.is_a?( Hash ) && !slice.empty?
      s = nil
      slice.values.each do |v|
        s = find_first_slice( v )
        break if s
      end
      return s if s
    elsif slice.is_a?( Array ) && !slice.empty?
      s = nil
      slice.each do |i|
        s = find_first_slice( i )
        break if s
      end
      return s if s
    end
    #else
    return nil
  end

  def self.slice_to_s slice
    s = find_first_slice( slice )
    if s.is_a? Parslet::Slice
      if s.line_cache
        pos = s.line_and_column
        retval = "'#{s.inspect}' ( line #{pos[0]} column #{pos[1]} )"
      else
        retval = "'#{s.inspect}' ( inserted for AOR )"
      end
    else
      retval = slice.to_s
    end
    retval
  end

  def self.raised_rule jcr, rule_atom
    " rule at #{slice_to_s(jcr)} [ #{jcr} ] from rule at #{slice_to_s(rule_atom)}"
  end

  def self.rule_to_s( rule, shallow=true)
    if rule[:rule_name]
      if rule[:primitive_rule]
        retval = "$#{rule[:rule_name].to_s} =: #{ruletype_to_s( rule, shallow )}"
      else
        retval = "$#{rule[:rule_name].to_s} = #{ruletype_to_s( rule, shallow )}"
      end
    else
      retval = ruletype_to_s( rule, shallow )
    end
    return retval
  end

  def self.ruletype_to_s( rule, shallow=true )

    if rule[:primitive_rule]
      retval = value_to_s( rule[:primitive_rule] )
    elsif rule[:member_rule]
      retval = member_to_s( rule[:member_rule], shallow )
    elsif rule[:object_rule]
      retval = object_to_s( rule[:object_rule], shallow )
    elsif rule[:array_rule]
      retval = array_to_s( rule[:array_rule], shallow )
    elsif rule[:group_rule]
      retval = group_to_s( rule[:group_rule], shallow )
    elsif rule[:target_rule_name]
      retval = target_to_s( rule[:target_rule_name] )
    elsif rule[:rule_name]
      retval = "rule: #{rule[:rule_name].to_s}"
    elsif rule[:rule]
      retval = rule_to_s( rule[:rule], shallow )
    else
      retval = "** unknown rule definition ** #{rule}"
    end
    return retval

  end

  def self.rules_to_s( rules, shallow=true)
    retval = ""
    rules.each do |rule|
      if rule[:rule_name]
        next
      elsif rule[:choice_combiner]
        retval = retval + " | "
      elsif rule[:sequence_combiner]
        retval = retval + " , "
      end
      retval = retval + rule_to_s( rule, shallow ) + repetitions_to_s( rule )
    end
    return retval
  end

  def self.annotations_to_s( annotations )
    retval = ""
    annotations.each do |a|
      case
        when a[:unordered_annotation]
          retval = retval + "@{unordered}"
        when a[:not_annotation]
          retval = retval + "@{not}"
        when a[:root_annotation]
          retval = retval + "@{root}"
        else
          retval = retval + "@{ ** unknown annotation ** }"
      end
    end if annotations
    retval = retval + " " if retval.length != 0
    return retval
  end

  def self.target_to_s( jcr )
    return annotations_to_s( jcr[:annotations] ) + "$" + jcr[:rule_name].to_s
  end

  def self.repetitions_to_s rule
    retval = ""
    if rule[:optional]
      retval = "?"
    elsif rule[:one_or_more]
      retval = "+"
      if rule[:repetition_step]
        retval = "%" + rule[:repetition_step].to_s
      end
    elsif rule[:zero_or_more]
      retval = "*"
      retval = retval + "%" + rule[:repetition_step].to_s if rule[:repetition_step]
    elsif rule[:specific_repetition] && rule[:specific_repetition].is_a?( Parslet::Slice )
      retval = "*" + rule[:specific_repetition].to_s
    else
      if rule[:repetition_interval]
        min = "0"
        max = "INF"
        o = rule[:repetition_min]
        if o
          if o.is_a?(Parslet::Slice)
            min = o.to_s
          end
        end
        o = rule[:repetition_max]
        if o
          if o.is_a?(Parslet::Slice)
            max = o.to_s
          end
        end
        retval = "*"+min+".."+max
      end
      o = rule[:repetition_step]
      if o
        if o.is_a?( Parslet::Slice )
          retval = retval + "%" + o.to_s
        end
      end
    end
    retval = " " + retval if retval.length != 0
    return retval
  end

end
