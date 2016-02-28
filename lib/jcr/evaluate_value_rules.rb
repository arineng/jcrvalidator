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

module JCR

  def self.evaluate_value_rule jcr, rule_atom, data, econs

    push_trace_stack( econs, jcr )
    trace( econs, "Evaluating value rule starting at #{slice_to_s(jcr)}" )
    rules, annotations = get_rules_and_annotations( jcr, econs )
    trace( econs, "Value definition is #{value_to_s(rules[0])} against", data )

    retval = evaluate_reject( annotations, evaluate_values( rules[0], rule_atom, data, econs ), econs )
    trace( econs, "Value rule evaluation is #{retval.success}")
    pop_trace_stack( econs )
    return retval
  end

  def self.evaluate_values jcr, rule_atom, data, econs
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
        return bad_value( jcr, rule_atom, "integer", data ) unless data.is_a?( Fixnum )
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
        return bad_value( jcr, rule_atom, "float", data ) unless data.is_a?( Float )
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
        return bad_value( jcr, rule_atom, regex, data ) unless data.is_a? String
        return bad_value( jcr, rule_atom, regex, data ) unless data =~ regex

      #
      # ip addresses
      #

      when jcr[:ip4]
        return bad_value( jcr, rule_atom, "IPv4 Address", data ) unless data.is_a? String
        begin
          ip = IPAddr.new( data )
        rescue IPAddr::InvalidAddressError
          return bad_value( jcr, rule_atom, "IPv4 Address", data )
        end
        return bad_value( jcr, rule_atom, "IPv4 Address", data ) unless ip.ipv4?
      when jcr[:ip6]
        return bad_value( jcr, rule_atom, "IPv6 Address", data ) unless data.is_a? String
        begin
          ip = IPAddr.new( data )
        rescue IPAddr::InvalidAddressError
          return bad_value( jcr, rule_atom, "IPv6 Address", data )
        end
        return bad_value( jcr, rule_atom, "IPv6 Address", data ) unless ip.ipv6?

      #
      # domain names
      #

      when jcr[:fqdn]
        return bad_value( jcr, rule_atom, "Fully Qualified Domain Name", data ) unless data.is_a? String
        return bad_value( jcr, rule_atom, "Fully Qualified Domain Name", data ) if data.empty?
        a = data.split( '.' )
        a.each do |label|
          return bad_value( jcr, rule_atom, "Fully Qualified Domain Name", data ) if label.start_with?( '-' )
          return bad_value( jcr, rule_atom, "Fully Qualified Domain Name", data ) if label.end_with?( '-' )
          label.each_char do |char|
            unless (char >= 'a' && char <= 'z') \
              || (char >= 'A' && char <= 'Z') \
              || (char >= '0' && char <='9') \
              || char == '-'
              return bad_value( jcr, rule_atom, "Fully Qualified Domain Name", data )
            end
          end
        end
      when jcr[:idn]
        return bad_value( jcr, rule_atom, "Internationalized Domain Name", data ) unless data.is_a? String
        return bad_value( jcr, rule_atom, "Internationalized Domain Name", data ) if data.empty?
        a = data.split( '.' )
        a.each do |label|
          return bad_value( jcr, rule_atom, "Internationalized Domain Name", data ) if label.start_with?( '-' )
          return bad_value( jcr, rule_atom, "Internationalized Domain Name", data ) if label.end_with?( '-' )
          label.each_char do |char|
            unless (char >= 'a' && char <= 'z') \
              || (char >= 'A' && char <= 'Z') \
              || (char >= '0' && char <='9') \
              || char == '-' \
              || char.ord > 127
              return bad_value( jcr, rule_atom, "Internationalized Domain Name", data )
            end
          end
        end

      #
      # uri and uri templates
      #

      when jcr[:uri]
        return bad_value( jcr, rule_atom, "URI", data ) unless data.is_a?( String )
        uri = Addressable::URI.parse( data )
        return bad_value( jcr, rule_atom, "URI", data ) unless uri.is_a?( Addressable::URI )
      when jcr[:uri_template]
        t = jcr[:uri_template].to_s
        return bad_value( jcr, rule_atom, t, data ) unless data.is_a? String
        template = Addressable::Template.new( t )
        e = template.extract( data )
        if e == nil
          return bad_value( jcr, rule_atom, t, data )
        else
          e.each do |k,v|
            return bad_value( jcr, rule_atom, t, data ) unless v
          end
        end

      #
      # phone and email value rules
      #

      when jcr[:email]
        return bad_value( jcr, rule_atom, "Email Address", data ) unless data.is_a? String
        return bad_value( jcr, rule_atom, "Email Address", data ) unless EmailAddressValidator.validate( data, true )

      when jcr[:phone]
        return bad_value( jcr, rule_atom, "Phone Number", data ) unless data.is_a? String
        p = BigPhoney::PhoneNumber.new( data )
        return bad_value( jcr, rule_atom, "Phone Number", data ) unless p.valid?

      #
      # base64 values
      #

      when jcr[:base64]
        return bad_value( jcr, rule_atom, "Base 64 Data", data ) unless data.is_a? String
        return bad_value( jcr, rule_atom, "Base 64 Data", data ) if data.empty?
        pad_start = false
        data.each_char do |char|
          if pad_start && char != '='
            return bad_value( jcr, rule_atom, "Base 64 Data", data )
          elsif char == '='
            pad_start = true
          end
          unless (char >= 'a' && char <= 'z') \
              || (char >= 'A' && char <= 'Z') \
              || (char >= '0' && char <='9') \
              || char == '=' || char == '+' || char == '/'
            return bad_value( jcr, rule_atom, "Base 64 Data", data )
          end
        end

      #
      # time and date values
      #

      when jcr[:date_time]
        return bad_value( jcr, rule_atom, "Time and Date", data ) unless data.is_a? String
        begin
          Time.iso8601( data )
        rescue ArgumentError
          return bad_value( jcr, rule_atom, "Time and Date", data )
        end
      when jcr[:full_date]
        return bad_value( jcr, rule_atom, "Date", data ) unless data.is_a? String
        begin
          d = data + "T23:20:50.52Z"
          Time.iso8601( d )
        rescue ArgumentError
          return bad_value( jcr, rule_atom, "Date", data )
        end
      when jcr[:full_time]
        return bad_value( jcr, rule_atom, "Time", data ) unless data.is_a? String
        begin
          t = "1985-04-12T" + data + "Z"
          Time.iso8601( t )
        rescue ArgumentError
          return bad_value( jcr, rule_atom, "Time", data )
        end

      #
      # null
      #

      when jcr[:null]
        return bad_value( jcr, rule_atom, nil, data ) unless data == nil

      #
      # groups
      #

      when jcr[:group_rule]
        return evaluate_group_rule jcr[:group_rule], rule_atom, data, econs

      else
        raise "unknown value rule evaluation. this shouldn't happen"
    end
    return Evaluation.new( true, nil )
  end

  def self.bad_value jcr, rule_atom, expected, actual
    Evaluation.new( false, "expected #{expected} but got #{actual} for #{raised_rule(jcr,rule_atom)}" )
  end

  def self.value_to_s( jcr )

    case

      when jcr[:any]
        return "any"

      when jcr[:integer_v]
        return jcr[:integer_v].to_s
      when jcr[:integer]
        return jcr[:integer].to_s.to_i
      when jcr[:integer_min],jcr[:integer_max]
        min = jcr[:integer_min].to_s.to_i
        max = jcr[:integer_max].to_s.to_i
        return "#{min}..#{max}"

      when jcr[:float_v]
        return jcr[:float_v].to_s
      when jcr[:float]
        return jcr[:float].to_s.to_f
      when jcr[:float_min],jcr[:float_max]
        min = jcr[:float_min].to_s.to_f
        max = jcr[:float_max].to_s.to_f
        return "#{min}..#{max}"

      when jcr[:true_v]
        return "true"
      when jcr[:false_v]
        return "false"
      when jcr[:boolean_v]
        return "boolean"

      when jcr[:string]
        return "string"
      when jcr[:q_string]
        return "'#{jcr[:q_string].to_s}'"

      when jcr[:regex]
        return "/#{jcr[:regex].to_s}/"

      when jcr[:ip4]
        return "ip4"
      when jcr[:ip6]
        return "ip6"

      when jcr[:fqdn]
        return "fqdn"
      when jcr[:idn]
        return "idn"

      when jcr[:uri]
        return "URI"
      when jcr[:uri_template]
        return "URI template #{jcr[:uri_template].to_s}"

      when jcr[:email]
        return "email"

      when jcr[:phone]
        return "phone"

      when jcr[:base64]
        return "base64"

      when jcr[:date_time]
        return "date-time"
      when jcr[:full_date]
        return "full-date"
      when jcr[:full_time]
        return "full-time"

      when jcr[:null]
        return "null"

      when jcr[:group_rule]
        return "( ... )"

      else
        return "** unknown value rule **"
    end
  end

end
