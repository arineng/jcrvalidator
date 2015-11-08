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

    root(:jcr)

    rule(:jcr) { ( spcCmnt | directive ).repeat >> root_rule.maybe >> ( spcCmnt | directive | rule ).repeat }
    #! jcr = *( sp-cmt / directive ) [ root_rule ]
    #!       *( sp-cmt / directive / rule )
    #!

    rule(:spcCmnt)  { spaces | comment }
        #/ spcCmnt -> sp-cmt
        #! spcCmnt = spaces / comment
    rule(:spcCmnt?) { spcCmnt.repeat }
        #/ spcCmnt? -> *sp-cmt
    rule(:spaces)   { match('\s').repeat(1) }
        #! spaces = 1*( WSP / CR / LF )
    rule(:spaces?)  { spaces.maybe }
        #/ spaces? -> [ spaces ]
    rule(:comment)  { str(';') >> ( str('\;') | match('[^\r\n;]') ).repeat >> match('[\r\n;]') }
        #! comment = ";" *( "\;" / comment-char ) comment-end-char
        #! comment-char = HTAB / %x20-3A / %x3C-10FFFF
        #!            ; Any char other than ";" / CR / LF
        #! comment-end-char = CR / LF / ";"
        #!

    rule(:directive) { ( str('#') >> spaces? >> directive_def >> match('[\r\n]') ).as(:directive) }
        #! directive = "#" spaces? directive_def eol
    rule(:directive_def) { jcr_version_d | ruleset_id_d | import_d | tbd_directive_d }
        #! directive_def = jcr_version_d / ruleset_id_d / import_d /
        #!                 tbd_directive_d
    rule(:jcr_version_d) { (str('jcr-version') >> spaces >> integer.as(:major_version) >> str('.') >> integer.as(:minor_version)).as(:jcr_version_d) }
        #! jcr_version_d = jcr-version-kw spaces major_version "." minor_version
        #> jcr-version-kw = "jcr-version"
        #! major_version = integer
        #! minor_version = integer
    rule(:ruleset_id_d)  { (str('ruleset-id') >> spaces >> ruleset_id.as(:ruleset_id)).as(:ruleset_id_d) }
        #! ruleset_id_d = ruleset-id-kw spaces ruleset_id
        #> ruleset-id-kw = "ruleset-id"
    rule(:import_d)      { (str('import') >> spaces >> ruleset_id.as(:ruleset_id) >> ( spaces >> str('as') >> spaces >> ruleset_id_alias ).maybe).as(:import_d) }
        #! import_d = import-kw spaces ruleset_id
        #!            [ spaces as_kw ruleset_id_alias ]
        #> import-kw = "import"
        #> as-kw = "as"
    rule(:ruleset_id)        { match('[a-zA-Z]') >> match('[\S]').repeat }
        #! ruleset_id = ALPHA *not-space
        #! not-space = %x21-10FFFF
    rule(:ruleset_id_alias)  { name.as(:ruleset_id_alias) }
        #! ruleset_id_alias = name
    rule(:tbd_directive_d) { name.as(:directive_name) >> ( spaces >> match('[^\r\n]').repeat.as(:directive_parameters) ).maybe }
        #! tbd_directive_d = directive_name [ spaces directive_parameters ]
        #! directive_name = name
        #! directive_parameters = not_eol
        #! not_eol = HTAB / %x20-10FFFF
        #! eol = CR / LF
        #!

    rule(:root_rule) { primitive_rule | array_rule | object_rule | member_rule | group_rule } # N.B. Not target_rule_name
        #! root_rule = primitive_rule / array_rule / object_rule /
        #!             member_rule / group_rule
        #!

    rule(:rule) { ( rule_name >> spcCmnt? >> rule_def ).as(:rule) }
        #! rule = rule_name spcCmnt? rule_def
        #!

    rule(:rule_name)         { name.as(:rule_name) }
        #! rule_name = name
    rule(:target_rule_name)  { ((ruleset_id_alias >> str('.')).maybe >> rule_name).as(:target_rule_name) }
        #! target_rule_name  = [ ruleset_id_alias "." ] rule_name
    rule(:name)              { match('[a-zA-Z]') >> match('[a-zA-Z0-9\-_]').repeat }
        #! name              = ALPHA *( ALPHA / DIGIT / "-" / "_" )
        #!

    rule(:rule_def)          { type_rule | member_rule | group_rule }
        #! rule_def = type_rule / member_rule / group_rule
    rule(:type_rule)         { value_rule | target_rule_name }
        #! type_rule = value_rule / target_rule_name
    rule(:value_rule)         { primitive_rule | array_rule | object_rule }
        #! value_rule = primitive_rule / array_rule / object_rule
    rule(:member_rule)       { ( annotations >> member_name_spec >> spcCmnt? >> (type_rule | type_choice) ).as(:member_rule) }
        #! member_rule = annotations
        #!               member_name_spec spcCmnt? (type_rule / type_choice)
    rule(:member_name_spec)  { regex.as(:member_regex) | q_string.as(:member_name) }
        #! member_name_spec = regex / q_string
    rule(:type_choice)       { ( str('(') >> type_choice_items >> ( choice_combiner >> type_choice_items ).repeat >> str(')') ).as(:group_rule) }
        #! type_choice = "(" type_choice_items 
        #!               *( choice_combiner type_choice_items ) ")"
    rule(:type_choice_items) { spcCmnt? >> (type_choice | type_rule) >> spcCmnt? }
        #! type_choice_items = spcCmnt? ( type_choice / type_rule ) spcCmnt?
        #!

    rule(:annotations)       { ( str('@(') >> spcCmnt? >> annotation_set >> spcCmnt? >> str(')') >> spcCmnt? ).repeat }
        #! annotations = *( "@(" spcCmnt? annotation_set spcCmnt? ")" spcCmnt? )
    rule(:annotation_set)    { reject_annotation | unordered_annotation | root_annotation | tbd_annotation }
        #! annotation_set = reject_annotation / unordered_annotation /
        #!                  root_annotation / tbd_annotation
    rule(:reject_annotation) { str('reject').as(:reject_annotation) }
        #! reject_annotation = reject-kw
        #> reject-kw = "reject"
    rule(:unordered_annotation) { str('unordered').as(:unordered_annotation) }
        #! unordered_annotation = unordered-kw
        #> unordered-kw = "unordered"
    rule(:root_annotation)   { str('root').as(:root_annotation) }
        #! root_annotation = root-kw
        #> root-kw = "root"
    rule(:tbd_annotation)    { name.as(:annotation_name) >> ( spaces >> match('[^)]').as(:annotation_parameters) ).maybe }
        #! tbd_annotation = annotation_name [ spaces annotation_parameters ]
        #! annotation_name = name
        #! annotation_parameters = *( spaces / %x21-28 / %x2A-10FFFF )
        #!                       ; Not close bracket - ")"
        #!

    rule(:primitive_rule)        { ( annotations >> str(':') >> spcCmnt? >> ( primimitive_choice | primimitive_def ) ).as(:primitive_rule) }
        #! primitive_rule = annotations ":" spcCmnt?
        #!                  ( primimitive_choice / primimitive_def )
    rule(:primimitive_choice)      { ( annotations >> str('(') >> spcCmnt? >> prim_choice_items >> spcCmnt? >> str(')') ).as(:group_rule) }
        #! primimitive_choice = annotations 
        #!                "(" spcCmnt? prim_choice_items spcCmnt? ")"
    rule(:prim_choice_items) { prim_choice_item >> ( spcCmnt? >> choice_combiner >> spcCmnt? >> prim_choice_item ).repeat }
        #! prim_choice_items = prim_choice_item
        #!                      *( choice_combiner prim_choice_item )
    rule(:prim_choice_item) { ( (str(':') >> spcCmnt? >> primimitive_def) | primimitive_choice | target_rule_name).as(:primitive_rule) }
        #! prim_choice_item = ":" spcCmnt? primimitive_def /
        #!                    primimitive_choice / target_rule_name
        #!

    rule(:primimitive_def) {
        null_type | boolean_type | true_value | false_value |
        string_type | string_range | string_value | 
        float_type | float_range | float_value |
        integer_type | integer_range | integer_value | 
        ip4_type | ip6_type | fqdn_type | idn_type |
        uri_range | uri_type | phone_type | email_type |
        full_date_type | full_time_type | date_time_type |
        base64_type | any
    }
        #! primimitive_def = null_type / boolean_type / true_value / false_value /
        #!             string_type / string_range / string_value / 
        #!             float_type / float_range / float_value /
        #!             integer_type / integer_range / integer_value / 
        #!             ip4_type / ip6_type / fqdn_type / idn_type /
        #!             uri_range / uri_type / phone_type / email_type /
        #!             full_date_type / full_time_type / date_time_type /
        #!             base64_type / any
    rule(:null_type)      { str('null').as(:null) }
        #! null_type = null-kw
        #> null-kw = "null"
    rule(:boolean_type)   { str('boolean').as(:boolean_v) }
        #! boolean_type = boolean-kw
        #> boolean-kw = "boolean"
    rule(:true_value)      { str('true').as(:true_v) }
        #! true_value = true-kw
        #> true-kw = "true"
    rule(:false_value)     { str('false').as(:false_v) }
        #! false_value = false-kw
        #> false-kw = "false"
    rule(:string_type)    { str('string').as(:string) }
        #! string_type = string-kw
        #> string-kw = "string"
    rule(:string_value)    { q_string }
        #! string_value = q_string
    rule(:string_range)    { regex }
        #! string_range = regex
    rule(:float_type)     { str('float').as(:float_v) }
        #! float_type = float-kw
        #> float-kw = "float"
    rule(:float_range)     {
        float.as(:float_min) >> str('..') >> float.maybe.as(:float_max) | str('..') >> float.as(:float_max)
    }
        #! float_range = float_min ".." [ float_max ] / ".." float_max
        #! float_min = float
        #! float_max = float
    rule(:float_value)     { float.as(:float) }
        #! float_value = float
    rule(:integer_type)   { str('integer').as(:integer_v) }
        #! integer_type = integer-kw
        #> integer-kw = "integer"
    rule(:integer_range)   {
        integer.as(:integer_min) >> str('..') >> integer.maybe.as(:integer_max) | ( str('..') >> integer.as(:integer_max) )
    }
        #! integer_range = integer_min ".." [ integer_max ] / ".." integer_max
        #! integer_min = integer
        #! integer_max = integer
    rule(:integer_value)   { integer.as(:integer) }
        #! integer_value = integer
    rule(:ip4_type)       { str('ip4').as(:ip4) }
        #! ip4_type = ip4-kw
        #> ip4-kw = "ip4"
    rule(:ip6_type)       { str('ip6').as(:ip6) }
        #! ip6_type = ip6-kw
        #> ip6-kw = "ip6"
    rule(:fqdn_type)      { str('fqdn').as(:fqdn) }
        #! fqdn_type = fqdn-kw
        #> fqdn-kw = "fqdn"
    rule(:idn_type)       { str('idn').as(:idn) }
        #! idn_type = idn-kw
        #> idn-kw = "idn"
    rule(:uri_range)       { str('uri..') >> uri_template }
        #! uri_range = "uri.." uri_template
        #> uri-kw = "uri"
    rule(:uri_type)       { str('uri').as(:uri) }
        #! uri_type = uri-kw
    rule(:phone_type)     { str('phone').as(:phone) }
        #! phone_type = phone-kw
        #> phone-kw = "phone"
    rule(:email_type)     { str('email').as(:email) }
        #! email_type = email-kw
        #> email-kw = "email"
    rule(:full_date_type) { str('full-date').as(:full_date) }
        #! full-date_type = full-date-kw
        #> full-date-kw = "full-date"
    rule(:full_time_type) { str('full-time').as(:full_time) }
        #! full-time_type = full-time-kw
        #> full-time-kw = "full-time"
    rule(:date_time_type) { str('date-time').as(:date_time) }
        #! date-time_type = date-time-kw
        #> date-time-kw = "date-time"
    rule(:base64_type)    { str('base64').as(:base64) }
        #! base64_type = base64-kw
        #> base64-kw = "base64"
    rule(:any)         { str('any').as(:any) }
        #! any = any-kw
        #> any-kw = "any"
        #!

    rule(:object_rule)  { ( annotations >> (str(':') >> spcCmnt?).maybe >>
                        str('{') >> spcCmnt? >> object_items.maybe >> spcCmnt? >> str('}') ).as(:object_rule) }
        #! object_rule = annotations [ ":" spcCmnt? ] "{" spcCmnt? [ object_items spcCmnt? ] "}"
    rule(:object_items) { object_item >> (( spcCmnt? >> sequence_combiner >> spcCmnt? >> object_item ).repeat(1) |
                                          ( spcCmnt? >> choice_combiner >> spcCmnt? >> object_item ).repeat(1) ).maybe }
        #! object_items = object_item (*( sequence_combiner object_item ) /
        #!                             *( choice_combiner object_item ) )
    rule(:object_item ) { repetition.maybe >> spcCmnt? >> object_item_types }
        #! object_item = [ repetition spcCmnt? ] object_item_types
    rule(:object_item_types) { member_rule | target_rule_name | object_group }
        #! object_item_types = member_rule / target_rule_name / object_group
    rule(:object_group) { ( str('(') >> spcCmnt? >> object_items.maybe >> spcCmnt? >> str(')') ).as(:group_rule) }
        #! object_group = "(" spcCmnt? [ object_items spcCmnt? ] ")"
        #!

    rule(:array_rule)   { ( annotations >> (str(':') >> spcCmnt?).maybe >> 
                        str('[') >> spcCmnt? >> array_items.maybe >> spcCmnt? >> str(']') ).as(:array_rule) }
        #! array_rule = annotations [ ":" spcCmnt? ] "[" spcCmnt? [ array_items spcCmnt? ] "]"
    rule(:array_items)  { array_item >> (( spcCmnt? >> sequence_combiner >> spcCmnt? >> array_item ).repeat(1) |
                                         ( spcCmnt? >> choice_combiner >> spcCmnt? >> array_item ).repeat(1) ).maybe }
        #! array_items = array_item (*( sequence_combiner array_item ) /
        #!                           *( choice_combiner array_item ) )
    rule(:array_item)   { repetition.maybe >> spcCmnt? >> array_item_types }
        #! array_item = [ repetition ] spcCmnt? array_item_types
    rule(:array_item_types) { type_rule | array_group }
        #! array_item_types = type_rule / array_group
    rule(:array_group)  { ( str('(') >> spcCmnt? >> array_items.maybe >> spcCmnt? >> str(')') ).as(:group_rule) }
        #! array_group = "(" spcCmnt? [ array_items spcCmnt? ] ")"
        #!

    rule(:group_rule)   { ( annotations >> str('(') >> spcCmnt? >> group_items.maybe >> spcCmnt? >> str(')') ).as(:group_rule) }
        #! group_rule = annotations "(" spcCmnt? [ group_items spcCmnt? ] ")"
    rule(:group_items)  { group_item >> (( spcCmnt? >> sequence_combiner >> spcCmnt? >> group_item ).repeat(1) |
                                         ( spcCmnt? >> choice_combiner >> spcCmnt? >> group_item ).repeat(1) ).maybe }
        #! group_items = group_item (*( sequence_combiner group_item ) /
        #!                           *( choice_combiner group_item ) )
    rule(:group_item)   { repetition.maybe >> spcCmnt? >> group_item_types }
        #! group_item = [ repetition ] spcCmnt? group_item_types
    rule(:group_item_types) { type_rule | member_rule | group_group }
        #! group_item_types = type_rule / member_rule / group_group
    rule(:group_group)  { group_rule }
        #! group_group = group_rule
        #!

    rule(:sequence_combiner)  { str(',').as(:sequence_combiner) }
        #! sequence_combiner = spcCmnt? "," spcCmnt?
    rule(:choice_combiner)    { str('|').as(:choice_combiner) }
        #! choice_combiner = spcCmnt? "|" spcCmnt?
        #!

    rule(:repetition)          { optional | one_or_more | min_max_repetition | specific_repetition }
        #! repetition = optional / one_or_more / min_max_repetition /
        #!              min_repetition / max_repetition /
        #!              zero_or_more / specific_repetition
    rule(:optional)            { str('?').as(:optional) }
        #! optional = "?"
    rule(:one_or_more)         { str('+').as(:one_or_more) }
        #! one_or_more = "+"
        #! zero_or_more = "*"
    rule(:min_max_repetition)  {      # This includes zero_or_more, min_only and max_only cases
            p_integer.maybe.as(:repetition_min) >> spcCmnt? >> str('*').as(:repetition_interval) >> spcCmnt? >> p_integer.maybe.as(:repetition_max) }
        #! min_max_repetition = min_repeat spcCmnt? "*" spcCmnt? max_repeat
        #! min_repetition = min_repeat spcCmnt? "*"
        #! max_repetition = "*" spcCmnt? max_repeat
        #! min_repeat = p_integer
        #! max_repeat = p_integer
    rule(:specific_repetition) { p_integer.as(:specific_repetition) }
        #! specific_repetition = p_integer
        #!

    rule(:integer)   { str('-').maybe >> match('[0-9]').repeat(1) }
        #! integer = ["-"] 1*DIGIT
    rule(:p_integer) { match('[0-9]').repeat(1) }
        #! p_integer = 1*DIGIT
        #!

    rule(:float)     { str('-').maybe >> match('[0-9]').repeat(1) >> str('.' ) >> match('[0-9]').repeat(1) }
        #! float         = [ minus ] int frac [ exp ]
        #!                 ; From RFC 7159 except 'frac' required
        #! minus         = %x2D                          ; -
        #! plus          = %x2B                          ; +
        #! int           = zero / ( digit1-9 *DIGIT )
        #! digit1-9      = %x31-39                       ; 1-9
        #! frac          = decimal-point 1*DIGIT
        #! decimal-point = %x2E                          ; .
        #! exp           = e [ minus / plus ] 1*DIGIT
        #! e             = %x65 / %x45                   ; e E
        #! zero          = %x30                          ; 0
        #!

    rule(:q_string)  {
      str('"') >>
        ( str('\\') >> match('[^\r\n]') | str('"').absent? >> match('[^\r\n]') ).repeat.as(:q_string) >>
      str('"')
    }
        #! q_string = quotation-mark *char quotation-mark 
        #!            ; From RFC 7159
        #! char = unescaped /
        #!   escape (
        #!   %x22 /          ; "    quotation mark  U+0022
        #!   %x5C /          ; \    reverse solidus U+005C
        #!   %x2F /          ; /    solidus         U+002F
        #!   %x62 /          ; b    backspace       U+0008
        #!   %x66 /          ; f    form feed       U+000C
        #!   %x6E /          ; n    line feed       U+000A
        #!   %x72 /          ; r    carriage return U+000D
        #!   %x74 /          ; t    tab             U+0009
        #!   %x75 4HEXDIG )  ; uXXXX                U+XXXX
        #! escape = %x5C              ; \
        #! quotation-mark = %x22      ; "
        #! unescaped = %x20-21 / %x23-5B / %x5D-10FFFF
        #!

    rule(:regex)     { str('/') >> (str('\\/') | match('[^/]+')).repeat.as(:regex) >> str('/') >> regex_modifiers.maybe }
        #! regex = "/" *( escape "/" / not-slash ) "/" [ regex_modifiers ]
        #! not-slash = HTAB / CR / LF / %x20-2E / %x30-10FFFF
        #!             ; Any char except "/"
    rule(:regex_modifiers) { match('[isx]').repeat.as(:regex_modifiers) }
        #! regex_modifiers = *( "i" / "s" / "x" )
    rule(:uri_template) { ( match('[a-zA-Z{}]').repeat(1) >> str(':') >> match('[\S]').repeat(1) ).as(:uri_template) }
        #! uri_template = 1*ALPHA ":" not-space

  end

  class Transformer < Parslet::Transform

    rule(:rule_def=>simple(:primimitive_def)) { puts "found rule definition" }
    rule(:primimitive_def => simple(:x)) { puts "value sought is " + x }

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


