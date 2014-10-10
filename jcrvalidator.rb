require 'pp'
require 'parslet'


module JCRValidator

  class Parser < Parslet::Parser

    rule(:spaces) { match('\s').repeat(1) }
    rule(:spaces?) { spaces.maybe }

    rule(:rule_name) { (match('[\\w]') >> match('[a-zA-Z0-9\-_]').repeat).as(:rule_name) }
    rule(:integer)   { ( str('-').maybe >> match('[0-9]').repeat ) }
    rule(:p_integer)   { ( match('[0-9]').repeat ) }
    rule(:float)     { ( str('-').maybe >> match('[0-9]').repeat ) >> str('.' ) >> match('[0-9]').repeat(1) }
    rule(:uri_template) { match('[^\s]').repeat(1).as(:uri_template) }
    rule(:regex)     {
      str('/') >>
        ( str('\\') >> any | str('/').absent? >> any ).repeat.as(:regex) >>
      str('/')
    }
    rule(:q_string)  {
      str('"') >>
        ( str('\\') >> any | str('"').absent? >> any ).repeat.as(:q_string) >>
      str('"')
    }
    rule(:enum_item) {
      str('true').as(:boolean) | str('false').as(:boolean) |
      str('null').as(:null) | q_string | float.as(:float) | integer.as(:integer)
    }
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
    rule(:string)    { str('string').as(:string) >> spaces? >> regex.maybe }
    rule(:uri)       { str('uri').as(:uri) >> spaces? >> uri_template.maybe }
    rule(:integer_v) { str('integer').as(:integer_v) >> spaces? >>
      ( integer.maybe.as(:min) >> str('..') >> integer.maybe.as(:max) | ( str('..') >> integer.as(:max) ) ).maybe
    }
    rule(:float_v)   { str('float').as(:float_v) >> spaces? >>
      ( float.maybe.as(:min) >> str('..') >> float.maybe.as(:max) | ( str('..') >> float.as(:max) ) ).maybe
    }
    rule(:enumeration) { (str('<') >> spaces? >> enum_item >> ( spaces >> enum_item ).repeat.maybe >> spaces? >> str('>')).as(:enumeration) }
    rule(:value_def) {
      (
        ip4 | ip6 | fqdn | idn | phone | email | base64 | full_time | full_date | date_time |
        boolean | null | base64 | string | uri | integer_v | float_v | enumeration
      )
    }
    rule(:value_rule) { ( ( str(':') | str('VALUE') ) >> spaces? >> value_def >> spaces? ).as(:value_rule) }
    rule(:member_rule) {
      ( ( str('MEMBER') >> spaces ).maybe >> q_string.as(:member_name) >> spaces? >>
        ( rule_name.as(:target_rule_name) | value_rule) ).as(:member_rule)
    }
    rule(:object_def ) { str('?').maybe.as(:member_optional) >> spaces? >> ( member_rule | rule_name.as(:target_rule_name) ) }
    rule(:object_rule) { ( ( str('{') | str('OBJECT') ) >> spaces? >>
      object_def >> ( spaces? >> ( str(',') | str('/') | str('&' ) | str('AND') | str('OR') | str('DEPENDS') ) >>
      spaces? >> object_def ).repeat  >> spaces? >> ( str('}') | str('END_OBJECT') )
      ).as(:object_rule)
    }
    #rule(:array_rule) { }
    #rule(:group_rule) { }
    rule(:rules) { ( rule_name >> spaces? >> ( value_rule | member_rule | object_rule ) ).as(:rules) }
    #rule(:comments) { }
    #rule(:directives) { }
    rule(:top) { rules }

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


