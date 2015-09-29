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

module JCR

  class Evaluation
    attr_accessor :success, :reason
    def initialize success, reason
      @success = success
      @reason = reason
    end
  end

  def self.evaluate_rule jcr, rule_atom, data, mapping
    case
      when jcr[:rule]
        return evaluate_rule( jcr[:rule], rule_atom, data, mapping)
      when jcr[:value_rule]
        return evaluate_value_rule( jcr[:value_rule], rule_atom, data, mapping)
      when jcr[:group_rule]
        return evaluate_group_rule( jcr[:group_rule], rule_atom, data, mapping)
      else
        return Evaluation.new( true, nil )
    end
  end

  def self.evaluate_value_rule jcr, rule_atom, data, mapping
    case

      #
      # any
      #

      when jcr[:any]
        return Evaluation.new( true, nil )

      #
      # integers
      #

      when jcr[:integer_v]
        si = jcr[:integer_v].to_s
        if si == "integer"
          return bad_value( jcr, rule_atom, "integer", data ) unless data.is_a?( Fixnum )
        end
      when jcr[:integer]
        i = jcr[:integer].to_s.to_i
        return bad_value( jcr, rule_atom, i, data ) unless data == i
      when jcr[:integer_min],jcr[:integer_max]
        min = jcr[:integer_min].to_s.to_i
        return bad_value( jcr, rule_atom, min, data ) unless data >= min
        max = jcr[:integer_max].to_s.to_i
        return bad_value( jcr, rule_atom, max, data ) unless data <= max

      #
      # floats
      #

      when jcr[:float_v]
        sf = jcr[:float_v].to_s
        if sf == "float"
          return bad_value( jcr, rule_atom, "float", data ) unless data.is_a?( Float )
        end
      when jcr[:float]
        f = jcr[:float].to_s.to_f
        return bad_value( jcr, rule_atom, f, data ) unless data == f
      when jcr[:float_min],jcr[:float_max]
        min = jcr[:float_min].to_s.to_f
        return bad_value( jcr, rule_atom, min, data ) unless data >= min
        max = jcr[:float_max].to_s.to_f
        return bad_value( jcr, rule_atom, max, data ) unless data <= max

      #
      # boolean
      #

      when jcr[:true_v]
        return bad_value( jcr, rule_atom, "true", data ) unless data
      when jcr[:false_v]
        return bad_value( jcr, rule_atom, "false", data ) if data
      when jcr[:boolean_v]
        return bad_value( jcr, rule_atom, "boolean", data ) unless ( data.is_a?( TrueClass ) || data.is_a?( FalseClass ) )

      #
      # strings
      #

      when jcr[:string]
        return bad_value( jcr, rule_atom, "string", data ) unless data.is_a? String
      when jcr[:q_string]
        s = jcr[:q_string].to_s
        return bad_value( jcr, rule_atom, s, data ) unless data == s

      #
      # regex
      #

      when jcr[:regex]
        regex = Regexp.new( jcr[:regex].to_s )
        return bad_value( jcr, rule_atom, regex, data ) unless data =~ regex

      #
      # null
      #

      when jcr[:null]
        return bad_value( jcr, rule_atom, nil, data ) unless data == nil

      #
      # groups
      #

      when jcr[:group_rule]
        return evaluate_group_rule jcr[:group_rule], rule_atom, data, mapping

      #
      # TODO when all value types are coded, this needs to be changed to raise an exception
      #
      else
        return Evaluation.new( true, nil )
    end
    return Evaluation.new( true, nil )
  end

  def self.bad_value jcr, rule_atom, expected, actual
    Evaluation.new( false, "expected #{expected} but got #{actual} at #{jcr} from #{rule_atom}" )
  end

  def self.evaluate_group_rule jcr, rule_atom, data, mapping
    return Evaluation.new( true, nil )
  end

end
