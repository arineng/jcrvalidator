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

module JCR

  def self.evaluate_member_rule jcr, rule_atom, data, econs

    push_trace_stack( econs, jcr )
    trace( econs, "Evaluating member rule for key '#{data[0]}' starting at #{slice_to_s(jcr)} against ", data[1])
    trace_def( econs, "member", jcr, data )
    retval = evaluate_member( jcr, rule_atom, data, econs )
    trace_eval( econs, "Member", retval, jcr, data, "member" )
    pop_trace_stack( econs )
    return retval

  end

  def self.evaluate_member jcr, rule_atom, data, econs

    # unlike the other evaluate functions, here data is not just the json data.
    # it is an array, the first element being the member name or regex and the
    # second being the json data to be furthered on to other evaluation functions


    rules, annotations = get_rules_and_annotations( jcr )
    rule = merge_rules( rules )

    member_match = false

    if rule[:member_name]
      match_spec = rule[:member_name][:q_string].to_s
      if match_spec == data[ 0 ]
        member_match = true
      end
    else # must be regex
      regex = rule[:member_regex][:regex]
      if regex.is_a? Array
        match_spec = Regexp.new( "" )
        trace( econs, "Noting empty regular expression." )
      else
        match_spec = Regexp.new( rule[:member_regex][:regex].to_s )
      end
      if match_spec =~ data[ 0 ]
        member_match = true
      end
    end

    if member_match
      e = evaluate_rule( rule, rule_atom, data[ 1 ], econs )
      e.member_found = true
      return evaluate_not( annotations, e, econs )
    end

    return evaluate_not( annotations,
       Evaluation.new( false, "#{match_spec} does not match #{data[0]} for #{raised_rule( jcr, rule_atom)}" ), econs )

  end

  def self.member_to_s( jcr, shallow=true )
    rules, annotations = get_rules_and_annotations( jcr )
    retval = ""
    rule = merge_rules( rules )
    case
      when rule[:member_name]
        retval = %Q|"#{rule[:member_name][:q_string].to_s}"|
      when rule[:member_regex]
        retval = "/#{rule[:member_regex][:regex].to_s}/"
      else
        retval = "** unknown member rule **"
    end
    retval = retval + " : " + rule_to_s( rule, shallow )
    return annotations_to_s( annotations ) + retval
  end

end
