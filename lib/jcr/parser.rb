# Copyright (C) 2014-2016 American Registry for Internet Numbers (ARIN)
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

    rule(:jcr) { ( spcCmnt | directive | root_rule | rule ).repeat }
    #! jcr = *( sp-cmt / directive / root_rule / rule )
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
    rule(:wsp)      { match('[\t ]') }
        # WSP is a standard ABNF production so is not expanded here
    rule(:dsps)     { spcCmnt.repeat(1) | wsp.repeat(1) }
        #! DSPs =     ; Directive spaces
        #!        1*WSP /     ; When in one-line directive
        #!        1*spcCmnt   ; When in muti-line directive
    rule(:dsps?)    { dsps.maybe }
        #/ DSPs? -> [ DSPs ]
    rule(:comment)  { str(';') >> match('[^\r\n]').repeat >> match('[\r\n]') }
        #! comment = ";" *comment-char comment-end-char
        #! comment-char = HTAB / %x20-10FFFF
        #!            ; Any char other than CR / LF
        #! comment-end-char = CR / LF
        #!

    rule(:directive) { ( str('#') >> (one_line_directive | multi_line_directive) ).as(:directive) }
        #! directive = "#" (one_line_directive / multi_line_directive)
    rule(:one_line_directive) { ( dsps? >> ( directive_def | one_line_tbd_directive_d ) >> wsp.repeat >> match('[\r\n]') ) }
        #! one_line_directive = DSPs? 
        #!                      (directive_def / one_line_tbd_directive_d)
        #!                      *WSP eol
    rule(:multi_line_directive) { str('{') >> spcCmnt? >> (directive_def | multi_line_tbd_directive_d) >> spcCmnt? >> str('}') }
        #! multi_line_directive = "{" spcCmnt?
        #!                        ( directive_def /
        #!                          multi_line_tbd_directive_d )
        #!                        spcCmnt? "}"
    rule(:directive_def) { jcr_version_d | ruleset_id_d | import_d }
        #! directive_def = jcr_version_d / ruleset_id_d / import_d
    rule(:jcr_version_d) { ( str('jcr-version') >> dsps >>
                             non_neg_integer.as(:major_version) >> str('.') >> non_neg_integer.as(:minor_version) >>
                             ( dsps >> str('+') >> dsps? >> extension_id ).repeat
                           ).as(:jcr_version_d) }
        #! jcr_version_d = jcr-version-kw DSPs major_version
        #!                 "." minor_version
        #!                 *( DSPs "+" DSPs? extension_id )
        #> jcr-version-kw = "jcr-version"
        #! major_version = non_neg_integer
        #! minor_version = non_neg_integer
    rule(:extension_id)  { id }
        #! extension_id = id
    rule(:id)  { match('[a-zA-Z]') >> id_tail.repeat }
        #! id = ALPHA *id-tail
    rule(:id_tail)  { match('[^\s}]') }
        #! id-tail = %x21-7C / %x7E-10FFFF ; not spaces, not }
    rule(:ruleset_id_d)  { (str('ruleset-id') >> dsps >> ruleset_id.as(:ruleset_id)).as(:ruleset_id_d) }
        #! ruleset_id_d = ruleset-id-kw DSPs ruleset_id
        #> ruleset-id-kw = "ruleset-id"
    rule(:import_d)      { (str('import') >> dsps >> ruleset_id.as(:ruleset_id) >> ( dsps >> str('as') >> dsps >> ruleset_id_alias ).maybe).as(:import_d) }
        #! import_d = import-kw DSPs ruleset_id
        #!            [ DSPs as_kw DSPs ruleset_id_alias ]
        #> import-kw = "import"
        #> as-kw = "as"
    rule(:ruleset_id)        { id }
        #! ruleset_id = id
    rule(:ruleset_id_alias)  { name.as(:ruleset_id_alias) }
        #! ruleset_id_alias = name
    rule(:one_line_tbd_directive_d) { name.as(:directive_name) >> ( wsp >> match('[^\r\n]').repeat.as(:directive_parameters) ).maybe }
        #! one_line_tbd_directive_d = directive_name
        #!                            [ WSP one_line_directive_parameters ]
        #! directive_name = name
        #! one_line_directive_parameters = *not_eol
        #! not_eol = HTAB / %x20-10FFFF
        #! eol = CR / LF
    rule(:multi_line_tbd_directive_d) { name.as(:directive_name) >> ( spcCmnt.repeat(1) >> multi_line_directive_parameters.as(:directive_parameters) ).maybe }
        #! multi_line_tbd_directive_d = directive_name
        #!                   [ 1*spcCmnt multi_line_directive_parameters ]
    rule(:multi_line_directive_parameters) { multi_line_parameters }
        #! multi_line_directive_parameters = multi_line_parameters
    rule(:multi_line_parameters) { (comment | q_string | match('[^";}]')).repeat }
        #! multi_line_parameters = *(comment / q_string /
        #!                         not_multi_line_special)
        #! not_multi_line_special = spaces / %x21 / %x23-3A /
        #!                          %x3C-7C / %x7E-10FFFF ; not ", ; or }
        #!

    rule(:root_rule) { value_rule | group_rule } # N.B. Not target_rule_name
        #! root_rule = value_rule / group_rule
        #!

    rule(:rule) { ( annotations.as(:annotations) >>  str('$') >> rule_name >> spcCmnt? >> str('=') >> spcCmnt? >> rule_def ).as(:rule) }
        #! rule = annotations "$" rule_name spcCmnt?
        #!        "=" spcCmnt? rule_def
        #!

    rule(:rule_name)         { name.as(:rule_name) }
        #! rule_name = name
    rule(:target_rule_name)  { (annotations.as(:annotations) >> str('$') >> (ruleset_id_alias >> str('.')).maybe >> rule_name).as(:target_rule_name) }
        #! target_rule_name  = annotations "$"
        #!                     [ ruleset_id_alias "." ]
        #!                     rule_name
    rule(:name)              { match('[a-zA-Z]') >> match('[a-zA-Z0-9\-_]').repeat }
        #! name              = ALPHA *( ALPHA / DIGIT / "-" / "_" )
        #!

    rule(:rule_def)          { member_rule | (type_designator >> rule_def_type_rule) | 
                               value_rule | group_rule | target_rule_name }
        #! rule_def = member_rule / type_designator rule_def_type_rule /
        #!            value_rule / group_rule / target_rule_name
    rule(:type_designator)   { str('type') >> spcCmnt.repeat(1) | str(':') >> spcCmnt? }
        #! type_designator = type-kw 1*spcCmnt / ":" spcCmnt?
        #> type-kw = "type"
    rule(:rule_def_type_rule)     { value_rule | type_choice }
        #! rule_def_type_rule = value_rule / type_choice
    rule(:value_rule)         { primitive_rule | array_rule | object_rule }
        #! value_rule = primitive_rule / array_rule / object_rule
    rule(:member_rule)       { ( annotations >> member_name_spec >> spcCmnt? >> str(':') >> spcCmnt? >> type_rule ).as(:member_rule) }
        #! member_rule = annotations
        #!               member_name_spec spcCmnt? ":" spcCmnt? type_rule
    rule(:member_name_spec)  { regex.as(:member_regex) | q_string.as(:member_name) }
        #! member_name_spec = regex / q_string
    rule(:type_rule)         { value_rule | type_choice | target_rule_name }
        #! type_rule = value_rule / type_choice / target_rule_name
    rule(:type_choice)       { ( annotations >> str('(') >> type_choice_items >> ( choice_combiner >> type_choice_items ).repeat >> str(')') ).as(:group_rule) }
        #! type_choice = annotations "(" type_choice_items
        #!               *( choice_combiner type_choice_items ) ")"
    rule(:type_choice_items) { spcCmnt? >> (type_choice | type_rule) >> spcCmnt? }
        #! type_choice_items = spcCmnt? ( type_choice / type_rule ) spcCmnt?
        #!

    rule(:annotations)       { ( str('@{') >> spcCmnt? >> annotation_set >> spcCmnt? >> str('}') >> spcCmnt? ).repeat }
        #! annotations = *( "@{" spcCmnt? annotation_set spcCmnt? "}"
        #!                  spcCmnt? )
    rule(:annotation_set)    { not_annotation | unordered_annotation | root_annotation | tbd_annotation }
        #! annotation_set = not_annotation / unordered_annotation /
        #!                  root_annotation / tbd_annotation
    rule(:not_annotation) { str('not').as(:not_annotation) }
        #! not_annotation = not-kw
        #> not-kw = "not"
    rule(:unordered_annotation) { str('unordered').as(:unordered_annotation) }
        #! unordered_annotation = unordered-kw
        #> unordered-kw = "unordered"
    rule(:root_annotation)   { str('root').as(:root_annotation) }
        #! root_annotation = root-kw
        #> root-kw = "root"
    rule(:tbd_annotation)    { name.as(:annotation_name) >> ( spaces >> annotation_parameters.as(:annotation_parameters) ).maybe }
        #! tbd_annotation = annotation_name [ spaces annotation_parameters ]
        #! annotation_name = name
    rule(:annotation_parameters) { multi_line_parameters }
        #! annotation_parameters = multi_line_parameters
        #!

    rule(:primitive_rule)        { ( annotations >> primitive_def ).as(:primitive_rule) }
        #! primitive_rule = annotations primitive_def

    rule(:primitive_def) {
          string_type | string_range | string_value |
          null_type | boolean_type | true_value | false_value |
          double_type | float_type | float_range | float_value |
          integer_type | integer_range | integer_value |
          sized_int_type | sized_uint_type |
          ipv4_type | ipv6_type | ipaddr_type | fqdn_type | idn_type |
          uri_type | phone_type | email_type |
          datetime_type | date_type | time_type |
          hex_type | base32hex_type | base32_type | base64url_type | base64_type |
          any
    }
        #! primitive_def = string_type / string_range / string_value /
        #!             null_type / boolean_type / true_value /
        #!             false_value / double_type / float_type /
        #!             float_range / float_value /
        #!             integer_type / integer_range / integer_value /
        #!             sized_int_type / sized_uint_type / ipv4_type /
        #!             ipv6_type / ipaddr_type / fqdn_type / idn_type /
        #!             uri_type / phone_type / email_type /
        #!             datetime_type / date_type / time_type /
        #!             hex_type / base32hex_type / base32_type /
        #!             base64url_type / base64_type / any
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
    rule(:double_type)     { str('double').as(:double_v) }
        #! double_type = double-kw
        #> double-kw = "double"
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
        #! integer_range = integer_min ".." [ integer_max ] /
        #!                 ".." integer_max
        #! integer_min = integer
        #! integer_max = integer
    rule(:integer_value)   { integer.as(:integer) }
        #! integer_value = integer
    rule(:sized_int_type)   { ( str('int') >> pos_integer.as(:bits) ).as(:sized_int_v) }
        #! sized_int_type = int-kw pos_integer
        #> int-kw = "int"
    rule(:sized_uint_type)   { ( str('uint') >> pos_integer.as(:bits) ).as(:sized_uint_v) }
        #! sized_uint_type = uint-kw pos_integer
        #> uint-kw = "uint"
    rule(:ipv4_type)       { str('ipv4').as(:ipv4) }
        #! ipv4_type = ipv4-kw
        #> ipv4-kw = "ipv4"
    rule(:ipv6_type)       { str('ipv6').as(:ipv6) }
        #! ipv6_type = ipv6-kw
        #> ipv6-kw = "ipv6"
    rule(:ipaddr_type)       { str('ipaddr').as(:ipaddr) }
        #! ipaddr_type = ipaddr-kw
        #> ipaddr-kw = "ipaddr"
    rule(:fqdn_type)      { str('fqdn').as(:fqdn) }
        #! fqdn_type = fqdn-kw
        #> fqdn-kw = "fqdn"
    rule(:idn_type)       { str('idn').as(:idn) }
        #! idn_type = idn-kw
        #> idn-kw = "idn"
    rule(:uri_type)       { (str('uri') >> ( str("..") >> uri_scheme ).maybe).as(:uri) }
        #! uri_type = uri-kw [ ".." uri-scheme ]
        #> uri-kw = "uri"
    rule(:phone_type)     { str('phone').as(:phone) }
        #! phone_type = phone-kw
        #> phone-kw = "phone"
    rule(:email_type)     { str('email').as(:email) }
        #! email_type = email-kw
        #> email-kw = "email"
    rule(:datetime_type) { str('datetime').as(:datetime) }
        #! datetime_type = datetime-kw
        #> datetime-kw = "datetime"
    rule(:date_type) { str('date').as(:date) }
        #! date_type = date-kw
        #> date-kw = "date"
    rule(:time_type) { str('time').as(:time) }
        #! time_type = time-kw
        #> time-kw = "time"
    rule(:hex_type)    { str('hex').as(:hex) }
        #! hex_type = hex-kw
        #> hex-kw = "hex"
    rule(:base32hex_type)    { str('base32hex').as(:base32hex) }
        #! base32hex_type = base32hex-kw
        #> base32hex-kw = "base32hex"
    rule(:base32_type)    { str('base32').as(:base32) }
        #! base32_type = base32-kw
        #> base32-kw = "base32"
    rule(:base64url_type)    { str('base64url').as(:base64url) }
        #! base64url_type = base64url-kw
        #> base64url-kw = "base64url"
    rule(:base64_type)    { str('base64').as(:base64) }
        #! base64_type = base64-kw
        #> base64-kw = "base64"
    rule(:any)         { str('any').as(:any) }
        #! any = any-kw
        #> any-kw = "any"
        #!

    rule(:object_rule)  { ( annotations >>
              str('{') >> spcCmnt? >> object_items.maybe >> spcCmnt? >> str('}') ).as(:object_rule) }
        #! object_rule = annotations "{" spcCmnt?
        #!                               [ object_items spcCmnt? ] "}"
    rule(:object_items) { object_item >> (( sequence_combiner >> object_item ).repeat(1) |
                                          ( choice_combiner >> object_item ).repeat(1) ).maybe }
        #! object_items = object_item [ 1*( sequence_combiner object_item ) /
        #!                             1*( choice_combiner object_item ) ]
    rule(:object_item ) { object_item_types >> spcCmnt? >> ( repetition >> spcCmnt? ).maybe }
        #! object_item = object_item_types spcCmnt? [ repetition spcCmnt? ]
    rule(:object_item_types) { object_group | member_rule | target_rule_name }
        #! object_item_types = object_group / member_rule / target_rule_name
    rule(:object_group) { ( annotations >> str('(') >> spcCmnt? >> object_items.maybe >> spcCmnt? >> str(')') ).as(:group_rule) }
        #! object_group = annotations "(" spcCmnt? [ object_items spcCmnt? ] ")"
        #!

      rule(:array_rule)   { ( annotations >>
              str('[') >> spcCmnt? >> array_items.maybe >> spcCmnt? >> str(']') ).as(:array_rule) }
        #! array_rule = annotations "[" spcCmnt? [ array_items spcCmnt? ] "]"
    rule(:array_items)  { array_item >> (( sequence_combiner >> array_item ).repeat(1) |
                                         ( choice_combiner >> array_item ).repeat(1) ).maybe }
        #! array_items = array_item [ 1*( sequence_combiner array_item ) /
        #!                           1*( choice_combiner array_item ) ]
    rule(:array_item)   { array_item_types >> spcCmnt? >> ( repetition >> spcCmnt? ).maybe }
        #! array_item = array_item_types spcCmnt? [ repetition spcCmnt? ]
    rule(:array_item_types) { array_group | type_rule }
        #! array_item_types = array_group / type_rule
    rule(:array_group)  { ( annotations >> str('(') >> spcCmnt? >> array_items.maybe >> spcCmnt? >> str(')') ).as(:group_rule) }
        #! array_group = annotations "(" spcCmnt? [ array_items spcCmnt? ] ")"
        #!

    rule(:group_rule)   { ( annotations >> str('(') >> spcCmnt? >> group_items.maybe >> spcCmnt? >> str(')') ).as(:group_rule) }
        #! group_rule = annotations "(" spcCmnt? [ group_items spcCmnt? ] ")"
    rule(:group_items)  { group_item >> (( sequence_combiner >> group_item ).repeat(1) |
                                         ( choice_combiner >> group_item ).repeat(1) ).maybe }
        #! group_items = group_item [ 1*( sequence_combiner group_item ) /
        #!                           1*( choice_combiner group_item ) ]
    rule(:group_item)   { group_item_types >> spcCmnt? >> ( repetition >> spcCmnt? ).maybe }
        #! group_item = group_item_types spcCmnt? [ repetition spcCmnt? ]
    rule(:group_item_types) { group_group | member_rule | type_rule }
        #! group_item_types = group_group / member_rule / type_rule
    rule(:group_group)  { group_rule }
        #! group_group = group_rule
        #!

    rule(:sequence_combiner)  { str(',').as(:sequence_combiner) >> spcCmnt? }
        #! sequence_combiner = "," spcCmnt?
    rule(:choice_combiner)    { str('|').as(:choice_combiner) >> spcCmnt? }
        #! choice_combiner = "|" spcCmnt?
        #!

    rule(:repetition)          { optional | one_or_more |
                                 repetition_range | zero_or_more }
        #! repetition = optional / one_or_more /
        #!              repetition_range / zero_or_more
    rule(:optional)            { str('?').as(:optional) }
        #! optional = "?"
    rule(:one_or_more)         { str('+').as(:one_or_more) >> repetition_step.maybe }
        #! one_or_more = "+" [ repetition_step ]
    rule(:zero_or_more)        { str('*').as(:zero_or_more) >> repetition_step.maybe }
        #! zero_or_more = "*" [ repetition_step ]
    rule(:repetition_range)    { str('*') >> spcCmnt? >>
                                 (min_max_repetition | specific_repetition) }
        #! repetition_range = "*" spcCmnt? (
        #!                             min_max_repetition / min_repetition /
        #!                             max_repetition / specific_repetition )
    rule(:min_max_repetition)  {      # This includes min_only and max_only cases
            non_neg_integer.maybe.as(:repetition_min) >>
            str("..").as(:repetition_interval) >>
            non_neg_integer.maybe.as(:repetition_max) >>
            repetition_step.maybe }
        #! min_max_repetition = min_repeat ".." max_repeat
        #!                     [ repetition_step ]
        #! min_repetition = min_repeat ".." [ repetition_step ]
        #! max_repetition = ".."  max_repeat [ repetition_step ]
        #! min_repeat = non_neg_integer
        #! max_repeat = non_neg_integer
    rule(:specific_repetition) { non_neg_integer.as(:specific_repetition) }
        #! specific_repetition = non_neg_integer
    rule(:repetition_step) { str('%') >> non_neg_integer.as(:repetition_step) }
        #! repetition_step = "%" step_size
        #! step_size = non_neg_integer
        #!

    rule(:integer)   { str('0') | str('-').maybe >> pos_integer }
        #! integer = "0" / ["-"] pos_integer
    rule(:non_neg_integer) { str('0') | pos_integer }
        #! non_neg_integer = "0" / pos_integer
    rule(:pos_integer) { match('[1-9]') >> match('[0-9]').repeat }
        #! pos_integer = digit1-9 *DIGIT
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
        ( match('\.') | match('[^"]') ).repeat.as(:q_string) >>
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
        #! regex = "/" *( escape re_escape_code / not-slash ) "/"
        #!         [ regex_modifiers ]
        #! re_escape_code = %x20-7F ; Specific codes listed elsewhere
        #! not-slash = HTAB / CR / LF / %x20-2E / %x30-10FFFF
        #!             ; Any char except "/"
    rule(:regex_modifiers) { match('[isx]').repeat.as(:regex_modifiers) }
        #! regex_modifiers = *( "i" / "s" / "x" )
        #!

    rule(:uri_scheme) { ( match('[a-zA-Z]').repeat(1) ).as(:uri_scheme) }
        #! uri_scheme = 1*ALPHA

  end

  class Transformer < Parslet::Transform

    rule(:rule_def=>simple(:primitive_def)) { puts "found rule definition" }
    rule(:primitive_def => simple(:x)) { puts "value sought is " + x }

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


