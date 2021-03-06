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
require 'addressable/uri'
require 'addressable/template'
require 'email_address_validator'
require 'big-phoney'

require 'jcr/parser'
require 'jcr/map_rule_names'
require 'jcr/check_groups'
require 'jcr/evaluate_rules'

module JCR

  def self.evaluate_group_rule jcr, rule_atom, data, econs, behavior = nil, target_annotations = nil

    push_trace_stack( econs, jcr )
    trace( econs, "Evaluating group rule against ", data )
    trace_def( econs, "group", jcr, data )
    retval = evaluate_group( jcr, rule_atom, data, econs, behavior, target_annotations )
    trace_eval( econs, "Group", retval, jcr, data, "group" )
    pop_trace_stack( econs )
    return retval

  end

  def self.evaluate_group jcr, rule_atom, data, econs, behavior = nil, target_annotations = nil

    rules, annotations = get_rules_and_annotations( jcr )

    retval = nil

    rules.each do |rule|
      if rule[:choice_combiner] && retval && retval.success
        return evaluate_not( annotations, retval, econs, target_annotations ) # short circuit
      elsif rule[:sequence_combiner] && retval && !retval.success
        return evaluate_not( annotations, retval, econs, target_annotations ) # short circuit
      end
      retval = evaluate_rule( rule, rule_atom, data, econs, behavior )
    end

    return evaluate_not( annotations, retval, econs, target_annotations )
  end

  def self.group_to_s( jcr, shallow=true)
    rules, annotations = get_rules_and_annotations( jcr )
    return "#{annotations_to_s( annotations)}( #{rules_to_s(rules,shallow)} )"
  end

end
