# Copyright (C) 2014 American Registry for Internet Numbers (ARIN)
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
require 'pp'
require 'parslet'


module JCRValidator

  class Parser < Parslet::Parser

    rule(:spaces) { match('\s').repeat(1) }
    rule(:spaces?) { spaces.maybe }
    rule(:comment)   { str(';') >> match('[^\r\n]').repeat.maybe >> match('[\r\n]') }
    rule(:spcCmnt?)   { spaces? >> comment.maybe >> spaces? }

    rule(:rule_name) { (match('[a-zA-Z]') >> match('[a-zA-Z0-9\-_]').repeat).as(:rule_name) }
    rule(:integer)   { ( str('-').maybe >> match('[0-9]').repeat ) }
    rule(:p_integer)   { ( match('[0-9]').repeat ) }
    rule(:float)     { str('-').maybe >> match('[0-9]').repeat(1) >> str('.' ) >> match('[0-9]').repeat(1) }
    rule(:uri) { match('[\S]').repeat(1) }
    rule(:uri_template) { match('[\S]').repeat(1).as(:uri_template) }
    rule(:regex)     {
      str('/') >>
        ( str('\\') >> match('[^\r\n]') | str('/').absent? >> match('[^\r\n]') ).repeat.as(:regex) >>
      str('/')
    }
    rule(:q_string)  {
      str('"') >>
        ( str('\\') >> match('[^\r\n]') | str('"').absent? >> match('[^\r\n]') ).repeat.as(:q_string) >>
      str('"')
    }
    rule(:enum_item) {
      str('true').as(:boolean) | str('false').as(:boolean) |
      str('null').as(:null) | q_string | float.as(:float) | integer.as(:integer)
    }
    rule(:any)       { str('any').as(:any) }
    rule(:ip4)       { str('ip4').as(:ip4) }
    rule(:ip6)       { str('ip6').as(:ip6) }
    rule(:fqdn)      { str('fqdn').as(:fqdn) }
    rule(:idn)       { str('idn').as(:idn) }
    rule(:phone)     { str('phone').as(:phone) }
    rule(:email)     { str('email').as(:email) }
    rule(:base64)    { str('base64').as(:base64) }
    rule(:full_date) { str('full-date').as(:full_date) }
    rule(:full_time) { str('full-time').as(:full_time) }
    rule(:date_time) { str('date-time').as(:date_time) }
    rule(:boolean)   { str('boolean').as(:boolean) }
    rule(:null)      { str('null').as(:null) }
    rule(:base64)    { str('base64').as(:base64) }
    rule(:string)    { str('string').as(:string) >> spcCmnt? >> regex.maybe }
    rule(:uri)       { str('uri').as(:uri) >> spcCmnt? >> uri_template.maybe }
    rule(:integer_v) { str('integer').as(:integer_v) >> spcCmnt? >>
      ( integer.maybe.as(:min) >> str('..') >> integer.maybe.as(:max) | ( str('..') >> integer.as(:max) ) ).maybe
    }
    rule(:float_v)   { str('float').as(:float_v) >> spcCmnt? >>
      ( ( float.as(:min) >> str('..') >> float.as(:max) ) | ( str('..') >> float.as(:max) ) |
          float.as(:min) >> str('..') ).maybe
    }
    rule(:enumeration) { (str('<') >> spcCmnt? >> enum_item >> ( spaces >> enum_item ).repeat.maybe >> spcCmnt? >> str('>')).as(:enumeration) }
    rule(:value_def) {
      (
        any | ip4 | ip6 | fqdn | idn | phone | email | base64 | full_time | full_date | date_time |
        boolean | null | base64 | string | uri | float_v | integer_v | enumeration
      )
    }
    rule(:value_rule) { ( str(':') >> spcCmnt? >> value_def ).as(:value_rule) }
    rule(:member_rule) {
      ( str('^').as(:any_member).maybe >> q_string.as(:member_name) >> spcCmnt? >>
      ( value_rule | rule_name.as(:target_rule_name) ) ).as(:member_rule)
    }
    rule(:object_repetition) {
      str('?').as(:member_optional) | ( p_integer.as(:repetition_min) >> str('*') >> p_integer.maybe.as(:repetition_max) ) |
      ( str('*') >> p_integer.as(:repetition_max) )
    }
    rule(:object_def ) { object_repetition.maybe >> spcCmnt? >> ( group_rule | member_rule | rule_name.as(:target_rule_name) ) }
    rule(:object_rule) { ( str('{') >> spcCmnt? >>
      object_def >> ( spcCmnt? >> ( str(',') | str('/') ) >>
      spcCmnt? >> object_def ).repeat  >> spcCmnt? >> str('}')
      ).as(:object_rule)
    }
    rule(:array_repetition) { (p_integer.as(:repetition_min) >> str('*') >> p_integer.maybe.as(:repetition_max)) |
      (str('*') >> p_integer.as(:repetition_max))
    }
    rule(:array_def)  { array_repetition.maybe >> spcCmnt? >> ( group_rule | array_rule | object_rule | value_rule | rule_name.as(:target_rule_name) ) }
    rule(:array_rule) { ( str('[') >> spcCmnt? >> array_def >> spcCmnt? >>
      ( str(',') >> spcCmnt? >> array_def ).repeat >> spcCmnt? >> str(']') ).as(:array_rule)
    }
    rule(:group_def)  {
      group_rule | array_rule | object_rule | value_rule | rule_name.as(:target_rule_name)
    }
    rule(:group_rule) { ( str('(') >> spcCmnt? >> group_def >> spcCmnt? >>
      ( ( str(',') | str('/') ) >> spcCmnt? >> group_def ).repeat >>
      spcCmnt? >> str(')') ).as(:group_rule)
    }
    rule(:rules) { spcCmnt? >> ( rule_name >> spcCmnt? >>
      ( value_rule | member_rule | object_rule | array_rule | group_rule ) ).as(:rule) >> spcCmnt?
    }
    rule(:ignore_unknown_members) { str('ignore-unknown-members').as(:ignore_unknown_members) }
    rule(:language_compatible_members) { str('language-compatible-members').as(:language_compatible_members) }
    rule(:all_members_optional) { str('all-members-optional').as(:all_members_optional) }
    rule(:include_d) { str('include').as(:include) >> spaces >> q_string.as(:collection) >> (spaces >> uri.as(:uri)).maybe }
    rule(:directive_def) { ignore_unknown_members | language_compatible_members | all_members_optional | include_d }
    rule(:directives) { ( str('#') >> spaces? >> directive_def >> match('[^\r\n]').repeat.maybe >> match('[\r\n]') ).as(:directive) }
    rule(:top) { ( rules | directives ).repeat }

    root(:top)
  end

  class Transformer < Parslet::Transform

    rule(:rule_def=>simple(:value_def)) { puts "found rule definition" }
    rule(:value_def => simple(:x)) { puts "value sought is " + x }

  end

  def self.parse(str)

    parser = Parser.new
    parser.parse(str)

  rescue Parslet::ParseFailed => failure

    puts failure.cause.ascii_tree

  end

  def self.parseAndTransform(str)

    parser = Parser.new
    tree = parser.parse(str)
    pp tree

    transformer = Transformer.new
    transformer.apply( tree )

  rescue Parslet::ParseFailed => failure

    puts failure.cause.ascii_tree

  end

end


