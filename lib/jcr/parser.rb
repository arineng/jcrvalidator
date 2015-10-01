# Copyright (C) 2014,2015 American Registry for Internet Numbers (ARIN)
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


module JCR

  class Parser < Parslet::Parser

    rule(:spaces) { match('\s').repeat(1) }
    rule(:spaces?) { spaces.maybe }
    rule(:comment)   { str(';') >> ( str('\;') | match('[^\r\n;]') ).repeat.maybe >> match('[\r\n;]') }
    rule(:spcCmnt?)   { spaces? >> comment.maybe >> spaces? }

	rule(:name)      { match('[a-zA-Z]') >> match('[a-zA-Z0-9\-_]').repeat }
    rule(:rule_name) { name.as(:rule_name) }
	rule(:namespace_alias) { name.as(:namespace_alias) }
	rule(:target_rule_name) { ((namespace_alias >> str('.')).maybe >> rule_name).as(:target_rule_name) }
    rule(:integer)   { ( str('-').maybe >> match('[0-9]').repeat ) }
    rule(:p_integer)   { ( match('[0-9]').repeat ) }
    rule(:float)     { str('-').maybe >> match('[0-9]').repeat(1) >> str('.' ) >> match('[0-9]').repeat(1) }
    rule(:uri) { match('[a-zA-Z]').repeat(1) >> str(':') >> match('[\S]').repeat(1) }
    rule(:uri_template) { ( match('[a-zA-Z{}]').repeat(1) >> str(':') >> match('[\S]').repeat(1) ).as(:uri_template) }
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
    rule(:true_v)    { str('true').as(:true_v) }
    rule(:false_v)   { str('false').as(:false_v) }
    rule(:boolean_v) { str('boolean').as(:boolean_v) }
    rule(:null)      { str('null').as(:null) }
    rule(:string)    { str('string').as(:string) }
    rule(:uri_v)     { str('uri').as(:uri) }
    rule(:integer_v) { str('integer').as(:integer_v) }
    rule(:integer_r) {
      integer.maybe.as(:integer_min) >> str('..') >> integer.maybe.as(:integer_max) | ( str('..') >> integer.as(:integer_max) )
    }
    rule(:float_v)   { str('float').as(:float_v) }
    rule(:float_r)   {
        ( float.as(:float_min) >> str('..') >> float.as(:float_max) ) |
        ( str('..') >> float.as(:float_max) ) |
        float.as(:float_min) >> str('..')
    }
    rule(:sequence_combiner)   { str(',').as(:sequence_combiner) }
    rule(:choice_combiner)    { str('|').as(:choice_combiner) }
    rule(:sequence_or_choice) { sequence_combiner | choice_combiner }
    rule(:value_def) {
      (
        any | ip4 | ip6 | fqdn | idn | phone | email | full_time | full_date | date_time |
        null | base64 | string | uri_v | float_v | integer_v | float_r | integer_r | boolean_v |
        true_v | false_v | q_string | uri_template | regex | float.as(:float) | integer.as(:integer)
      )
    }
    rule(:value_rule) { ( str(':') >> spcCmnt? >> ( group_rule | value_def ) ).as(:value_rule) }

    rule(:min_max_repetition) { ( p_integer.as(:repetition_min) >> spcCmnt? >> str('*') >> spcCmnt? >> p_integer.maybe.as(:repetition_max) ) |
            ( str('*') >> spcCmnt? >> p_integer.as(:repetition_max) ) }
    rule(:member_rule) {
      ( ( regex.as(:member_regex) | q_string.as(:member_name) ) >> spcCmnt? >> type_rule ).as(:member_rule)
    }

    rule(:object_def ) { min_max_repetition.maybe >> spcCmnt? >> ( group_rule | member_rule | target_rule_name ) }
    rule(:object_rule) { ( str('{') >> spcCmnt? >>
      object_def >> ( spcCmnt? >> sequence_or_choice >>
      spcCmnt? >> object_def ).repeat  >> spcCmnt? >> str('}')
      ).as(:object_rule)
    }

    rule(:array_def)  { min_max_repetition.maybe >> spcCmnt? >> type_rule }
    rule(:array_rule) { ( str('[') >> spcCmnt? >> array_def >>
      ( spcCmnt? >> sequence_or_choice >> spcCmnt? >> array_def ).repeat >> spcCmnt? >> str(']') ).as(:array_rule)
    }

    rule(:group_def)  { min_max_repetition.maybe >> spcCmnt? >> ( type_rule | member_rule ) }
    rule(:group_rule) { ( str('(') >> spcCmnt? >> group_def >> spcCmnt? >>
      ( spcCmnt? >> sequence_or_choice >> spcCmnt? >> group_def ).repeat >>
      spcCmnt? >> str(')') ).as(:group_rule)
    }

	rule(:type_rule) { value_rule | group_rule | array_rule | object_rule | target_rule_name }
    rule(:rules) { spcCmnt? >> ( rule_name >> spcCmnt? >>
      ( type_rule | member_rule ) ).as(:rule) >> spcCmnt? }

    rule(:pedantic) { str('pedantic').as(:pedantic) }
    rule(:language_compatible_members) { str('language-compatible-members').as(:language_compatible_members) }
    rule(:jcr_version_d) { str('jcr-version') >> spaces >> float }
    rule(:ruleset_id_d) { str('ruleset-id') >> spaces >> uri.as(:uri) }
    rule(:import_d) { str('import') >> spaces >> uri.as(:uri) >> ( spaces >> str('as') >> spaces >> namespace_alias ).maybe }
    rule(:directive_def) { pedantic | language_compatible_members | jcr_version_d | ruleset_id_d | import_d }
    rule(:directive) { ( str('#') >> spaces? >> directive_def >> match('[^\r\n]').repeat.maybe >> match('[\r\n]') ).as(:directive) }
    rule(:top) { ( rules | directive ).repeat }

    root(:top)
  end

  class Transformer < Parslet::Transform

    rule(:rule_def=>simple(:value_def)) { puts "found rule definition" }
    rule(:value_def => simple(:x)) { puts "value sought is " + x }

  end

  def self.parse(str)

    parser = Parser.new
    parser.parse(str)

  end

  def self.parse_and_transform(str)
    # provided for the fun of it

    parser = Parser.new
    tree = parser.parse(str)
    pp tree

    transformer = Transformer.new
    transformer.apply( tree )

  end

  def self.print_tree( tree )

    tree.each do |node|
      puts "named rule: " + node[:rule][:rule_name] if node[:rule]
    end

  end

end


