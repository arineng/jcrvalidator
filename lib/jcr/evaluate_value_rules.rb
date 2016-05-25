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
    trace_def( econs, "value", jcr, data )
    rules, annotations = get_rules_and_annotations( jcr )

    retval = evaluate_not( annotations, evaluate_values( rules[0], rule_atom, data, econs ), econs )
    trace_eval( econs, "Value", retval)
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
      when jcr[:sized_int_v]
        bits = jcr[:sized_int_v][:bits].to_i
        return bad_value( jcr, rule_atom, "int" + bits.to_s, data ) unless data.is_a?( Fixnum )
        min = -(2**(bits-1))
        return bad_value( jcr, rule_atom, min, data ) unless data >= min
        max = 2**(bits-1)-1
        return bad_value( jcr, rule_atom, max, data ) unless data <= max
      when jcr[:sized_uint_v]
        bits = jcr[:sized_uint_v][:bits].to_i
        return bad_value( jcr, rule_atom, "int" + bits.to_s, data ) unless data.is_a?( Fixnum )
        min = 0
        return bad_value( jcr, rule_atom, min, data ) unless data >= min
        max = 2**bits-1
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
      when jcr[:double_v]
        sf = jcr[:double_v].to_s
        if sf == "double"
          return bad_value( jcr, rule_atom, "double", data ) unless data.is_a?( Float )
        end

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

      when jcr[:ipv4]
        return bad_value( jcr, rule_atom, "IPv4 Address", data ) unless data.is_a? String
        begin
          ip = IPAddr.new( data )
        rescue IPAddr::InvalidAddressError
          return bad_value( jcr, rule_atom, "IPv4 Address", data )
        end
        return bad_value( jcr, rule_atom, "IPv4 Address", data ) unless ip.ipv4?
      when jcr[:ipv6]
        return bad_value( jcr, rule_atom, "IPv6 Address", data ) unless data.is_a? String
        begin
          ip = IPAddr.new( data )
        rescue IPAddr::InvalidAddressError
          return bad_value( jcr, rule_atom, "IPv6 Address", data )
        end
        return bad_value( jcr, rule_atom, "IPv6 Address", data ) unless ip.ipv6?
      when jcr[:ipaddr]
        return bad_value( jcr, rule_atom, "IP Address", data ) unless data.is_a? String
        begin
          ip = IPAddr.new( data )
        rescue IPAddr::InvalidAddressError
          return bad_value( jcr, rule_atom, "IP Address", data )
        end
        return bad_value( jcr, rule_atom, "IP Address", data ) unless ip.ipv6? || ip.ipv4?

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
      # hex values
      #

      when jcr[:hex]
        return bad_value( jcr, rule_atom, "Hex Data", data ) unless data.is_a? String
        return bad_value( jcr, rule_atom, "Hex Data", data ) unless data.length % 2 == 0
        pad_start = false
        data.each_char do |char|
          unless (char >= '0' && char <='9') \
              || (char >= 'A' && char <= 'F') \
              || (char >= 'a' && char <= 'f')
            return bad_value( jcr, rule_atom, "Hex Data", data )
          end
        end

      #
      # base32hex values
      #

      when jcr[:base32hex]
        return bad_value( jcr, rule_atom, "Base32hex Data", data ) unless data.is_a? String
        return bad_value( jcr, rule_atom, "Base32hex Data", data ) unless data.length % 8 == 0
        pad_start = false
        data.each_char do |char|
          if char == '='
            pad_start = true
          elsif pad_start && char != '='
            return bad_value( jcr, rule_atom, "Base32hex Data", data )
          else 
              unless (char >= '0' && char <='9') \
                  || (char >= 'A' && char <= 'V') \
                  || (char >= 'a' && char <= 'v')
                return bad_value( jcr, rule_atom, "Base32hex Data", data )
              end
          end
        end

      #
      # base32 values
      #

      when jcr[:base32]
        return bad_value( jcr, rule_atom, "Base 32 Data", data ) unless data.is_a? String
        return bad_value( jcr, rule_atom, "Base 32 Data", data ) unless data.length % 8 == 0
        pad_start = false
        data.each_char do |char|
          if char == '='
            pad_start = true
          elsif pad_start && char != '='
            return bad_value( jcr, rule_atom, "Base 32 Data", data )
          else 
              unless (char >= 'a' && char <= 'z') \
                  || (char >= 'A' && char <= 'Z') \
                  || (char >= '2' && char <='7')
                return bad_value( jcr, rule_atom, "Base 32 Data", data )
              end
          end
        end

      #
      # base64url values
      #

      when jcr[:base64url]
        return bad_value( jcr, rule_atom, "Base64url Data", data ) unless data.is_a? String
        return bad_value( jcr, rule_atom, "Base64url Data", data ) unless data.length % 4 == 0
        pad_start = false
        data.each_char do |char|
          if char == '='
            pad_start = true
          elsif pad_start && char != '='
            return bad_value( jcr, rule_atom, "Base64url Data", data )
          else 
              unless (char >= 'a' && char <= 'z') \
                  || (char >= 'A' && char <= 'Z') \
                  || (char >= '0' && char <='9') \
                  || char == '-' || char == '_'
                return bad_value( jcr, rule_atom, "Base64url Data", data )
              end
          end
        end

      #
      # base64 values
      #

      when jcr[:base64]
        return bad_value( jcr, rule_atom, "Base 64 Data", data ) unless data.is_a? String
        return bad_value( jcr, rule_atom, "Base 64 Data", data ) unless data.length % 4 == 0
        pad_start = false
        data.each_char do |char|
          if char == '='
            pad_start = true
          elsif pad_start && char != '='
            return bad_value( jcr, rule_atom, "Base 64 Data", data )
          else 
              unless (char >= 'a' && char <= 'z') \
                  || (char >= 'A' && char <= 'Z') \
                  || (char >= '0' && char <='9') \
                  || char == '+' || char == '/'
                return bad_value( jcr, rule_atom, "Base 64 Data", data )
              end
          end
        end

      #
      # time and date values
      #

      when jcr[:datetime]
        return bad_value( jcr, rule_atom, "Time and Date", data ) unless data.is_a? String
        begin
          Time.iso8601( data )
        rescue ArgumentError
          return bad_value( jcr, rule_atom, "Time and Date", data )
        end
      when jcr[:date]
        return bad_value( jcr, rule_atom, "Date", data ) unless data.is_a? String
        begin
          d = data + "T23:20:50.52Z"
          Time.iso8601( d )
        rescue ArgumentError
          return bad_value( jcr, rule_atom, "Date", data )
        end
      when jcr[:time]
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

  def self.value_to_s( jcr, shallow=true )

    rules, annotations = get_rules_and_annotations( jcr )

    rule = rules[ 0 ]
    retval = ""
    case

      when rule[:any]
        retval =  "any"

      when rule[:integer_v]
        retval =  rule[:integer_v].to_s
      when rule[:integer]
        retval =  rule[:integer].to_s.to_i
      when rule[:integer_min],rule[:integer_max]
        min = rule[:integer_min].to_s.to_i
        max = rule[:integer_max].to_s.to_i
        retval =  "#{min}..#{max}"
      when rule[:sized_int_v]
        retval =  "int" + rule[:sized_int_v][:bits].to_s
      when rule[:sized_uint_v]
        retval =  "uint" + rule[:sized_uint_v][:bits].to_s

      when rule[:double_v]
        retval =  rule[:double_v].to_s
      when rule[:float_v]
        retval =  rule[:float_v].to_s
      when rule[:float]
        retval =  rule[:float].to_s.to_f
      when rule[:float_min],rule[:float_max]
        min = rule[:float_min].to_s.to_f
        max = rule[:float_max].to_s.to_f
        retval =  "#{min}..#{max}"

      when rule[:true_v]
        retval =  "true"
      when rule[:false_v]
        retval =  "false"
      when rule[:boolean_v]
        retval =  "boolean"

      when rule[:string]
        retval =  "string"
      when rule[:q_string]
        retval =  %Q|"#{rule[:q_string].to_s}"|

      when rule[:regex]
        retval =  "/#{rule[:regex].to_s}/"

      when rule[:ipv4]
        retval =  "ipv4"
      when rule[:ipv6]
        retval =  "ipv6"

      when rule[:fqdn]
        retval =  "fqdn"
      when rule[:idn]
        retval =  "idn"

      when rule[:uri]
        retval =  "URI"
      when rule[:uri_template]
        retval =  "URI template #{rule[:uri_template].to_s}"

      when rule[:email]
        retval =  "email"

      when rule[:phone]
        retval =  "phone"

      when rule[:hex]
        retval =  "hex"
      when rule[:base32url]
        retval =  "base32url"
      when rule[:base64url]
        retval =  "base64url"
      when rule[:base64]
        retval =  "base64"

      when rule[:datetime]
        retval =  "datetime"
      when rule[:date]
        retval =  "date"
      when rule[:time]
        retval =  "time"

      when rule[:null]
        retval =  "null"

      when rule[:group_rule]
        retval =  group_to_s( rule[:group_rule], shallow )

      else
        retval =  "** unknown value rule **"
    end
    return annotations_to_s( annotations ) + retval.to_s
  end

end
