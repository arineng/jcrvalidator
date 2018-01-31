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
require 'spec_helper'
require 'rspec'
require 'pp'
require_relative '../lib/jcr/parser'

describe 'parser' do

=begin
  an example of printing out the ascii_tree

  it 'should parse an ipv4 value defintion 1' do
    begin
      tree = JCR.parse( '$trule = ipv4' )
        expect(tree[0][:rule][:rule_name]).to eq("trule")
        expect(tree[0][:rule][:primitive_rule][:ipv4]).to eq("ipv4")
      rescue Parslet::ParseFailed => failure

        puts failure.cause.ascii_tree
      end
  end
=end

  it 'should parse an ipv4 value defintion 1' do
    tree = JCR.parse( '$trule = type ipv4' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:primitive_rule][:ipv4]).to eq("ipv4")
  end

  it 'should parse an ipv4 value defintion 2' do
    tree = JCR.parse( '$trule = : ipv4' )
    expect(tree[0][:rule][:primitive_rule][:ipv4]).to eq("ipv4")
  end

  it 'should parse an ipv4 value defintion 3' do
    tree = JCR.parse( '$trule = :ipv4' )
    expect(tree[0][:rule][:primitive_rule][:ipv4]).to eq("ipv4")
  end

  it 'should parse an ipv4 value defintion 3' do
    tree = JCR.parse( '$trule = :ipv4 ' )
    expect(tree[0][:rule][:primitive_rule][:ipv4]).to eq("ipv4")
  end

  it 'should parse an ipv4 value defintion 4' do
    tree = JCR.parse( '$trule = ipv4 ' )
    expect(tree[0][:rule][:primitive_rule][:ipv4]).to eq("ipv4")
  end

  it 'should parse an ipv6 value defintion 1' do
    tree = JCR.parse( '$trule = type ipv6' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:primitive_rule][:ipv6]).to eq("ipv6")
  end
  it 'should parse an ipv6 value defintion 2' do
    tree = JCR.parse( '$trule = : ipv6' )
    expect(tree[0][:rule][:primitive_rule][:ipv6]).to eq("ipv6")
  end
  it 'should parse an ipv6 value defintion 3' do
    tree = JCR.parse( '$trule = type ipv6 ' )
    expect(tree[0][:rule][:primitive_rule][:ipv6]).to eq("ipv6")
  end

  it 'should parse an ipaddr value' do
    tree = JCR.parse( '$trule = type ipaddr' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:primitive_rule][:ipaddr]).to eq("ipaddr")
  end

  it 'should parse a string constant' do
    tree = JCR.parse( '$trule = type "a string constant"' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:primitive_rule][:q_string]).to eq("a string constant")
  end

  it 'should parse a string constant' do
    tree = JCR.parse( '$trule = :"a string constant"' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:primitive_rule][:q_string]).to eq("a string constant")
  end

  it 'should parse a string constant with extra space' do
    tree = JCR.parse( '$trule = type "a string constant" ' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:primitive_rule][:q_string]).to eq("a string constant")
  end

  it 'should parse a string' do
    tree = JCR.parse( '$trule = type string' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:primitive_rule][:string]).to eq("string")
  end

  it 'should parse a regex 1' do
    tree = JCR.parse( '$trule = type /a.regex.goes.here.*/' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:primitive_rule][:regex]).to eq("a.regex.goes.here.*")
  end

  it 'should parse a regex without leading colon' do
    tree = JCR.parse( '$trule = /a.regex.goes.here.*/' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:primitive_rule][:regex]).to eq("a.regex.goes.here.*")
  end

  it 'should parse a regex 2' do
    tree = JCR.parse( '$trule = type /a.regex\\.goes.here.*/' )
    expect(tree[0][:rule][:primitive_rule][:regex]).to eq("a.regex\\.goes.here.*")
  end

  it 'should parse a regex with a modifier' do
    tree = JCR.parse( '$trule = type /a.regex\\.goes.here.*/i' )
    expect(tree[0][:rule][:primitive_rule][:regex]).to eq("a.regex\\.goes.here.*")
    expect(tree[0][:rule][:primitive_rule][:regex_modifiers]).to eq("i")
  end

  it 'should parse a regex with a multiple modifiers' do
    tree = JCR.parse( '$trule = type /a.regex\\.goes.here.*/ixs' )
    expect(tree[0][:rule][:primitive_rule][:regex]).to eq("a.regex\\.goes.here.*")
    expect(tree[0][:rule][:primitive_rule][:regex_modifiers]).to eq("ixs")
  end

  it 'should parse a regex with a multiple modifiers and no extra space' do
    tree = JCR.parse( '$trule = type /a.regex\\.goes.here.*/ixs' )
    expect(tree[0][:rule][:primitive_rule][:regex]).to eq("a.regex\\.goes.here.*")
    expect(tree[0][:rule][:primitive_rule][:regex_modifiers]).to eq("ixs")
  end

  it 'should parse a regex followed by a rule' do
    tree = JCR.parse( '$trule = type /a.regex.goes.here.*/$context= :integer' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:primitive_rule][:regex]).to eq("a.regex.goes.here.*")
    expect(tree[0][:rule][:primitive_rule][:regex_modifiers]).to eq([])
    expect(tree[1][:rule][:rule_name]).to eq("context")
  end

  it 'should parse a regex with modifiers followed by a rule' do
    tree = JCR.parse( '$trule = type /a.regex.goes.here.*/si$des= :integer' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:primitive_rule][:regex]).to eq("a.regex.goes.here.*")
    expect(tree[0][:rule][:primitive_rule][:regex_modifiers]).to eq("si")
    expect(tree[1][:rule][:rule_name]).to eq("des")
  end

  it 'should parse a uri' do
    tree = JCR.parse( '$trule = type uri' )
    expect(tree[0][:rule][:primitive_rule][:uri]).to eq("uri")
  end

  it 'should parse a uri without type keyword' do
    tree = JCR.parse( '$trule = uri' )
    expect(tree[0][:rule][:primitive_rule][:uri]).to eq("uri")
  end

  it 'should parse a uri scheme' do
    tree = JCR.parse( '$trule = type uri..http' )
    expect(tree[0][:rule][:primitive_rule][:uri][:uri_scheme]).to eq("http")
  end

  it 'should parse a uri scheme with a value immediately succeeding' do
    tree = JCR.parse( '[ uri..http,uri..http ]' )
  end

  it 'should parse an any' do
    tree = JCR.parse( '$trule = type any' )
    expect(tree[0][:rule][:primitive_rule][:any]).to eq("any")
  end

  it 'should parse true' do
    tree = JCR.parse( '$trule = type true' )
    expect(tree[0][:rule][:primitive_rule][:true_v]).to eq("true")
  end

  it 'should parse false' do
    tree = JCR.parse( '$trule = type false' )
    expect(tree[0][:rule][:primitive_rule][:false_v]).to eq("false")
  end

  it 'should parse boolean' do
    tree = JCR.parse( '$trule = type boolean' )
    expect(tree[0][:rule][:primitive_rule][:boolean_v]).to eq("boolean")
  end

  it 'should parse boolean without type keyword' do
    tree = JCR.parse( '$trule = boolean' )
    expect(tree[0][:rule][:primitive_rule][:boolean_v]).to eq("boolean")
  end

  it 'should parse null' do
    tree = JCR.parse( '$trule = type null' )
    expect(tree[0][:rule][:primitive_rule][:null]).to eq("null")
  end

  it 'should parse a integer value without a range' do
    tree = JCR.parse( '$trule = type integer' )
    expect(tree[0][:rule][:primitive_rule][:integer_v]).to eq("integer")
  end

  it 'should parse a integer value without a range without type keyword' do
    tree = JCR.parse( '$trule = integer' )
    expect(tree[0][:rule][:primitive_rule][:integer_v]).to eq("integer")
  end

  it 'should parse a integer constant' do
    tree = JCR.parse( '$trule = type 2' )
    expect(tree[0][:rule][:primitive_rule][:integer]).to eq("2")
  end

  it 'should parse a integer constant without type keyword' do
    tree = JCR.parse( '$trule = 2' )
    expect(tree[0][:rule][:primitive_rule][:integer]).to eq("2")
  end

  it 'should parse a negative integer constant' do
    tree = JCR.parse( '$trule = :-2' )
    expect(tree[0][:rule][:primitive_rule][:integer]).to eq("-2")
  end

  it 'should parse a negative integer constant without : prefix' do
    tree = JCR.parse( '$trule = -2' )
    expect(tree[0][:rule][:primitive_rule][:integer]).to eq("-2")
  end

  it 'should parse an integer full range' do
    tree = JCR.parse( '$trule = :0..100' )
    expect(tree[0][:rule][:primitive_rule][:integer_min]).to eq("0")
    expect(tree[0][:rule][:primitive_rule][:integer_max]).to eq("100")
  end

  it 'should parse an integer full range without : prefix' do
    tree = JCR.parse( '$trule = 0..100' )
    expect(tree[0][:rule][:primitive_rule][:integer_min]).to eq("0")
    expect(tree[0][:rule][:primitive_rule][:integer_max]).to eq("100")
  end

  it 'should parse a negative integer range to positive integer' do
    tree = JCR.parse( '$trule = :-1..100' )
    expect(tree[0][:rule][:primitive_rule][:integer_min]).to eq("-1")
    expect(tree[0][:rule][:primitive_rule][:integer_max]).to eq("100")
  end

  it 'should parse a negative integer full range' do
    tree = JCR.parse( '$trule = :-100..-1' )
    expect(tree[0][:rule][:primitive_rule][:integer_min]).to eq("-100")
    expect(tree[0][:rule][:primitive_rule][:integer_max]).to eq("-1")
  end

  it 'should parse a negative integer full range without : prefix' do
    tree = JCR.parse( '$trule = -100..-1' )
    expect(tree[0][:rule][:primitive_rule][:integer_min]).to eq("-100")
    expect(tree[0][:rule][:primitive_rule][:integer_max]).to eq("-1")
  end

  it 'should parse an integer range with a min range' do
    tree = JCR.parse( '$trule = :0..' )
    expect(tree[0][:rule][:primitive_rule][:integer_min]).to eq("0")
  end

  it 'should parse an integer range with a min range without : prefix' do
    tree = JCR.parse( '$trule = 0..' )
    expect(tree[0][:rule][:primitive_rule][:integer_min]).to eq("0")
  end

  it 'should parse an integer rangge with a max range' do
    tree = JCR.parse( '$trule = :..100' )
    expect(tree[0][:rule][:primitive_rule][:integer_max]).to eq("100")
  end

  it 'should parse an integer rangge with a max range without : prefix' do
    tree = JCR.parse( '$trule = ..100' )
    expect(tree[0][:rule][:primitive_rule][:integer_max]).to eq("100")
  end

  it 'should parse a negative integer range with a max range' do
    tree = JCR.parse( '$trule = :..-100' )
    expect(tree[0][:rule][:primitive_rule][:integer_max]).to eq("-100")
  end

  it 'should parse a negative integer range with a max range without : prefix' do
    tree = JCR.parse( '$trule = ..-100' )
    expect(tree[0][:rule][:primitive_rule][:integer_max]).to eq("-100")
  end

  it 'should parse a sized int value without a range' do
    tree = JCR.parse( '$trule = :int32' )
    expect(tree[0][:rule][:primitive_rule][:sized_int_v][:bits]).to eq("32")
  end

  it 'should parse a sized int value without a range without : prefix' do
    tree = JCR.parse( '$trule = int32' )
    expect(tree[0][:rule][:primitive_rule][:sized_int_v][:bits]).to eq("32")
  end

  it 'should parse a sized int value without a range' do
    tree = JCR.parse( '$trule = :uint32' )
    expect(tree[0][:rule][:primitive_rule][:sized_uint_v][:bits]).to eq("32")
  end

  it 'should parse a double value' do
    tree = JCR.parse( '$trule = :double' )
    expect(tree[0][:rule][:primitive_rule][:double_v]).to eq("double")
  end

  it 'should parse a double value without : prefix' do
    tree = JCR.parse( '$trule = double' )
    expect(tree[0][:rule][:primitive_rule][:double_v]).to eq("double")
  end

  it 'should parse a float value' do
    tree = JCR.parse( '$trule = :float' )
    expect(tree[0][:rule][:primitive_rule][:float_v]).to eq("float")
  end

  it 'should parse a float constant' do
    tree = JCR.parse( '$trule = :2.0' )
    expect(tree[0][:rule][:primitive_rule][:float]).to eq("2.0")
  end

  it 'should parse a float constant without : prefix' do
    tree = JCR.parse( '$trule = 2.0' )
    expect(tree[0][:rule][:primitive_rule][:float]).to eq("2.0")
  end

  it 'should parse a negative float constant' do
    tree = JCR.parse( '$trule = :-2.0' )
    expect(tree[0][:rule][:primitive_rule][:float]).to eq("-2.0")
  end

  it 'should parse a negative float constant without : prefix' do
    tree = JCR.parse( '$trule = -2.0' )
    expect(tree[0][:rule][:primitive_rule][:float]).to eq("-2.0")
  end

  it 'should parse a float range with a full range' do
    tree = JCR.parse( '$trule = :0.0..100.0' )
    expect(tree[0][:rule][:primitive_rule][:float_min]).to eq("0.0")
    expect(tree[0][:rule][:primitive_rule][:float_max]).to eq("100.0")
  end

  it 'should parse a float range with a full range without : prefix' do
    tree = JCR.parse( '$trule = 0.0..100.0' )
    expect(tree[0][:rule][:primitive_rule][:float_min]).to eq("0.0")
    expect(tree[0][:rule][:primitive_rule][:float_max]).to eq("100.0")
  end

  it 'should parse a negative float range with a full range' do
    tree = JCR.parse( '$trule = :-100.0..-1.0' )
    expect(tree[0][:rule][:primitive_rule][:float_min]).to eq("-100.0")
    expect(tree[0][:rule][:primitive_rule][:float_max]).to eq("-1.0")
  end

  it 'should parse a float range with a min range' do
    tree = JCR.parse( '$trule = :0.3939..' )
    expect(tree[0][:rule][:primitive_rule][:float_min]).to eq("0.3939")
  end

  it 'should parse a float range with a min range without : prefix' do
    tree = JCR.parse( '$trule = 0.3939..' )
    expect(tree[0][:rule][:primitive_rule][:float_min]).to eq("0.3939")
  end

  it 'should parse a float range with a max range' do
    tree = JCR.parse( '$trule = :..100.003' )
    expect(tree[0][:rule][:primitive_rule][:float_max]).to eq("100.003")
  end

  it 'should parse a float range with a max range without : prefix' do
    tree = JCR.parse( '$trule = ..100.003' )
    expect(tree[0][:rule][:primitive_rule][:float_max]).to eq("100.003")
  end

  it 'should parse an value with group 1' do
    tree = JCR.parse( '$trule = :( 1.0 | 2 | true | "yes" | "Y" )' )
    expect(tree[0][:rule][:group_rule][0][:primitive_rule][:float]).to eq("1.0")
    expect(tree[0][:rule][:group_rule][1][:primitive_rule][:integer]).to eq("2")
    expect(tree[0][:rule][:group_rule][2][:primitive_rule][:true_v]).to eq("true")
    expect(tree[0][:rule][:group_rule][3][:primitive_rule][:q_string]).to eq("yes")
    expect(tree[0][:rule][:group_rule][4][:primitive_rule][:q_string]).to eq("Y")
  end

  it 'should parse a value with group 2' do
    tree = JCR.parse( '$trule = type ( "no" | false | 1.0 | 2 | true | "yes" | "Y" )' )
    expect(tree[0][:rule][:group_rule][0][:primitive_rule][:q_string]).to eq("no")
    expect(tree[0][:rule][:group_rule][1][:primitive_rule][:false_v]).to eq("false")
    expect(tree[0][:rule][:group_rule][2][:primitive_rule][:float]).to eq("1.0")
    expect(tree[0][:rule][:group_rule][3][:primitive_rule][:integer]).to eq("2")
    expect(tree[0][:rule][:group_rule][4][:primitive_rule][:true_v]).to eq("true")
    expect(tree[0][:rule][:group_rule][5][:primitive_rule][:q_string]).to eq("yes")
    expect(tree[0][:rule][:group_rule][6][:primitive_rule][:q_string]).to eq("Y")
  end

  it 'should parse a value with group 3' do
    tree = JCR.parse( '$trule = :( null | "no" | false | 1.0 | 2 | true | "yes" | "Y" )' )
    expect(tree[0][:rule][:group_rule][0][:primitive_rule][:null]).to eq("null")
    expect(tree[0][:rule][:group_rule][1][:primitive_rule][:q_string]).to eq("no")
    expect(tree[0][:rule][:group_rule][2][:primitive_rule][:false_v]).to eq("false")
    expect(tree[0][:rule][:group_rule][3][:primitive_rule][:float]).to eq("1.0")
    expect(tree[0][:rule][:group_rule][4][:primitive_rule][:integer]).to eq("2")
    expect(tree[0][:rule][:group_rule][5][:primitive_rule][:true_v]).to eq("true")
    expect(tree[0][:rule][:group_rule][6][:primitive_rule][:q_string]).to eq("yes")
    expect(tree[0][:rule][:group_rule][7][:primitive_rule][:q_string]).to eq("Y")
  end

  it 'should parse two rules' do
    tree = JCR.parse( '$vrule = :integer $mrule ="thing": $vrule' )
    expect(tree[0][:rule][:rule_name]).to eq("vrule")
    expect(tree[1][:rule][:rule_name]).to eq("mrule")
  end

  it 'should parse two rules without : prefix' do
    tree = JCR.parse( '$vrule = integer $mrule ="thing": $vrule' )
    expect(tree[0][:rule][:rule_name]).to eq("vrule")
    expect(tree[1][:rule][:rule_name]).to eq("mrule")
  end

  it 'should parse a member rule with float range with a max range 3' do
    tree = JCR.parse( '$trule = "thing" : ..100.003' )
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:primitive_rule][:float_max]).to eq("100.003")
  end

  it 'should parse a member rule with integer value' do
    tree = JCR.parse( '$trule = "thing" : integer' )
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:primitive_rule][:integer_v]).to eq("integer")
  end

  it 'should not parse a repetition member string rule with integer value' do
    expect{ tree = JCR.parse( '$trule = "thing" *1..2: integer' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should parse an any member rule with integer value' do
    tree = JCR.parse( '$trule = /.*/ : integer' )
    expect(tree[0][:rule][:member_rule][:member_regex][:regex]).to eq(".*")
    expect(tree[0][:rule][:member_rule][:primitive_rule][:integer_v]).to eq("integer")
  end

  it 'should parse an any member rule of /.*/' do
    tree = JCR.parse( '$trule = /.*/ : integer' )
    expect(tree[0][:rule][:member_rule][:member_regex][:regex]).to eq(".*")
    expect(tree[0][:rule][:member_rule][:primitive_rule][:integer_v]).to eq("integer")
  end

  it 'should parse an regex member rule with string value' do
    tree = JCR.parse( '$trule = /a.regex\\.goes.here.*/ : string' )
    expect(tree[0][:rule][:member_rule][:member_regex][:regex]).to eq("a.regex\\.goes.here.*")
    expect(tree[0][:rule][:member_rule][:primitive_rule][:string]).to eq("string")
  end

  it 'should parse a member rule with an email value 2' do
    tree = JCR.parse( '$trule = "thing" : email' )
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:primitive_rule][:email]).to eq("email")
  end

  it 'should parse a member rule with integer range with a max range 1' do
    tree = JCR.parse( '$trule = "thing" : ..100' )
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:primitive_rule][:integer_max]).to eq("100")
  end

  it 'should parse a member rule with a rule name' do
    tree = JCR.parse( '$trule = "thing" : $my_value_rule' )
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:target_rule_name][:rule_name]).to eq("my_value_rule")
  end

  it 'should parse a member rule with a rule name with an annotation' do
    tree = JCR.parse( '$trule = "thing" : @{id foo } $my_value_rule' )
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:target_rule_name][:rule_name]).to eq("my_value_rule")
  end

  it 'should parse a member rule with a choice rule' do
    tree = JCR.parse( '$trule = "thing" : ( $an_array | $an_object )' )
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:group_rule][0][:target_rule_name][:rule_name]).to eq("an_array")
    expect(tree[0][:rule][:member_rule][:group_rule][1][:target_rule_name][:rule_name]).to eq("an_object")
  end

  it 'should parse a member rule with a choice rule' do
    tree = JCR.parse( '$trule = "thing" : ( @{when $t == "array"} $an_array | $an_object )' )
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:group_rule][0][:target_rule_name][:rule_name]).to eq("an_array")
    expect(tree[0][:rule][:member_rule][:group_rule][1][:target_rule_name][:rule_name]).to eq("an_object")
  end

  it 'should fail a member rule with a and rule' do
    expect{ JCR.parse( '$trule = "thing" : ( $an_array , $an_object )' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should fail a member rule with choice and and rule' do
    expect{ JCR.parse( '$trule = "thing" : ( $an_array | $a_string , $an_object )' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should parse a member rule with group of three ands' do
    expect{ JCR.parse( '$trule = "thing" : ( $an_array , $a_string , $an_object )' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should parse a member rule with group of three ors' do
    tree = JCR.parse( '$trule = "thing" : ( $an_array | $a_string | $an_object )' )
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:group_rule][0][:target_rule_name][:rule_name]).to eq("an_array")
    expect(tree[0][:rule][:member_rule][:group_rule][1][:target_rule_name][:rule_name]).to eq("a_string")
    expect(tree[0][:rule][:member_rule][:group_rule][2][:target_rule_name][:rule_name]).to eq("an_object")
  end

  it 'should parse a member rule with an object rule' do
    tree = JCR.parse( '$trule = "thing" : { $an_array, $an_object }' )
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("an_array")
    expect(tree[0][:rule][:member_rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("an_object")
  end

  it 'should parse a member rule with an array rule' do
    tree = JCR.parse( '$trule = "thing" : [ $an_array, $an_object ]' )
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:array_rule][0][:target_rule_name][:rule_name]).to eq("an_array")
    expect(tree[0][:rule][:member_rule][:array_rule][1][:target_rule_name][:rule_name]).to eq("an_object")
  end

  it 'should parse an empty object rule' do
    tree = JCR.parse( '$trule = :{ }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an empty object rule without type designator' do
    tree = JCR.parse( '$trule = { }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an object rule with rule names' do
    tree = JCR.parse( '$trule = :{ $my_rule1, $my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with rule names or`ed' do
    tree = JCR.parse( '$trule = :{ $my_rule1 | $my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with embeded member rules with names 1' do
    tree = JCR.parse( '$trule = :{ "thing" : $my_value_rule, $my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:target_rule_name][:rule_name]).to eq("my_value_rule")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with embeded member rules with names or`ed`' do
    tree = JCR.parse( '$trule = :{ "thing" : $my_value_rule| $my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:target_rule_name][:rule_name]).to eq("my_value_rule")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with embeded member rules with value rule 1' do
    tree = JCR.parse( '$trule = :{ "thing" : ..100.003, $my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:primitive_rule][:float_max]).to eq("100.003")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with rule name, embeded member rules with value, rule name' do
    tree = JCR.parse( '$trule = :{ $my_rule1, "thing" : ..100.003, $my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][1][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:object_rule][1][:member_rule][:primitive_rule][:float_max]).to eq("100.003")
    expect(tree[0][:rule][:object_rule][2][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse a member rule as an object rule with rule name, embeded member rules with value, rule name' do
    tree = JCR.parse( '$trule = "mem_rule": { $my_rule1, "thing" : ..100.003, $my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("mem_rule")
    expect(tree[0][:rule][:member_rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:member_rule][:object_rule][1][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:object_rule][1][:member_rule][:primitive_rule][:float_max]).to eq("100.003")
    expect(tree[0][:rule][:member_rule][:object_rule][2][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with preceding colon' do
    tree = JCR.parse( '$trule = "mem_rule" : { $my_rule1, $my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("mem_rule")
    expect(tree[0][:rule][:member_rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:member_rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with embeded member rules with value rule ored' do
    tree = JCR.parse( '$trule = :{ "thing" : ..100.003| $my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:primitive_rule][:float_max]).to eq("100.003")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with embeded member rules with value rule spelled out 1' do
    tree = JCR.parse( '$trule = :{ "thing" : ..100.003, $my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:primitive_rule][:float_max]).to eq("100.003")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with rule names with optionality 1' do
    tree = JCR.parse( '$trule = type { $my_rule1, $my_rule2 *..1 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:object_rule][1][:repetition_min]).to eq(nil)
    expect(tree[0][:rule][:object_rule][1][:repetition_max]).to eq("1")
    expect(tree[0][:rule][:object_rule][1][:repetition_step]).to eq(nil)
  end

  it 'should parse an object rule with rule names with optionality 4 step 2' do
    tree = JCR.parse( '$trule = type { $my_rule1, $my_rule2 *..4%2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:object_rule][1][:repetition_min]).to eq(nil)
    expect(tree[0][:rule][:object_rule][1][:repetition_max]).to eq("4")
    expect(tree[0][:rule][:object_rule][1][:repetition_step]).to eq("2")
  end

  it 'should parse an object rule with rule names with optional repetition' do
    tree = JCR.parse( '$trule = type { $my_rule1, $my_rule2 ? }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:object_rule][1][:optional]).to eq('?')
  end

  it 'should parse an object rule with rule names with zero or many repetition' do
    tree = JCR.parse( '$trule = :{ $my_rule1, $my_rule2 * }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:object_rule][1][:zero_or_more]).to eq('*')
    expect(tree[0][:rule][:object_rule][1][:repetition_step]).to eq(nil)
  end

  it 'should parse an object rule with rule names with zero or many repetition step 2' do
    tree = JCR.parse( '$trule = :{ $my_rule1, $my_rule2 *%2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:object_rule][1][:zero_or_more]).to eq('*')
    expect(tree[0][:rule][:object_rule][1][:repetition_step]).to eq('2')
  end

  it 'should parse an object rule with rule names with one or many repetition' do
    tree = JCR.parse( '$trule = :{ $my_rule1, $my_rule2 +}' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:object_rule][1][:one_or_more]).to eq('+')
  end

  it 'should parse an object rule with rule names with one or many repetition step 2' do
    tree = JCR.parse( '$trule = :{ $my_rule1, $my_rule2 +%2}' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:object_rule][1][:one_or_more]).to eq('+')
    expect(tree[0][:rule][:object_rule][1][:repetition_step]).to eq('2')
  end

  it 'should parse an object rule with rule names with 2 repetition' do
    tree = JCR.parse( '$trule = :{ $my_rule1, $my_rule2 *2}' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:object_rule][1][:specific_repetition]).to eq('2')
    expect(tree[0][:rule][:object_rule][1][:repetition_step]).to eq(nil)
  end

  it 'should parse an object rule with rule names with optionality 2' do
    tree = JCR.parse( '$trule = :{ $my_rule1 *..1, $my_rule2 *..1 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][0][:repetition_min]).to eq(nil)
    expect(tree[0][:rule][:object_rule][0][:repetition_max]).to eq("1")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:object_rule][1][:repetition_min]).to eq(nil)
    expect(tree[0][:rule][:object_rule][1][:repetition_max]).to eq("1")
  end

  it 'should parse an object rule with rule names with optionality with or' do
    tree = JCR.parse( '$trule = :{ $my_rule1*..1| $my_rule2 *..1}' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][0][:repetition_min]).to eq(nil)
    expect(tree[0][:rule][:object_rule][0][:repetition_max]).to eq("1")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:object_rule][1][:repetition_min]).to eq(nil)
    expect(tree[0][:rule][:object_rule][1][:repetition_max]).to eq("1")
  end

  it 'should parse an object rule with embeded member rules with value rule with optionality 1' do
    tree = JCR.parse( '$trule = :{ "thing" : ..100.003 *0..1, $my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:object_rule][0][:repetition_min]).to eq("0")
    expect(tree[0][:rule][:object_rule][0][:repetition_max]).to eq("1")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:primitive_rule][:float_max]).to eq("100.003")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with rule names with optionality for any rules' do
    tree = JCR.parse( '$trule = :{ $my_rule1, $my_rule2 *1..2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an empty array rule' do
    tree = JCR.parse( '$trule = :[ ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an empty array rule without a type designator' do
    tree = JCR.parse( '$trule = [ ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an array rule with rule names 1' do
    tree = JCR.parse( '$trule = :[ $my_rule1, $my_rule2 ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:array_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:array_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an array rule with preceding colon' do
    tree = JCR.parse( '$trule = :[ $my_rule1, $my_rule2 ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:array_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:array_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an array rule with rule names ored' do
    tree = JCR.parse( '$trule = :[ $my_rule1| $my_rule2 ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:array_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:array_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an array rule with rule names and repetition' do
    tree = JCR.parse( '$trule = :[ $my_rule1 *1..2, $my_rule2 *1.., $my_rule3 *..3 ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:array_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:array_rule][0][:repetition_min]).to eq("1")
    expect(tree[0][:rule][:array_rule][0][:repetition_max]).to eq("2")
    expect(tree[0][:rule][:array_rule][0][:repetition_step]).to eq(nil)
    expect(tree[0][:rule][:array_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:array_rule][1][:repetition_min]).to eq("1")
    expect(tree[0][:rule][:array_rule][1][:repetition_max]).to eq(nil)
    expect(tree[0][:rule][:array_rule][1][:repetition_step]).to eq(nil)
    expect(tree[0][:rule][:array_rule][2][:target_rule_name][:rule_name]).to eq("my_rule3")
    expect(tree[0][:rule][:array_rule][2][:repetition_min]).to eq(nil)
    expect(tree[0][:rule][:array_rule][2][:repetition_max]).to eq("3")
    expect(tree[0][:rule][:array_rule][2][:repetition_step]).to eq(nil)
  end

  it 'should parse an array rule with rule names and repetition and step' do
    tree = JCR.parse( '$trule = :[ $my_rule1 *0..4%2, $my_rule2 *1..%3, $my_rule3 *..9%3 ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:array_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:array_rule][0][:repetition_min]).to eq("0")
    expect(tree[0][:rule][:array_rule][0][:repetition_max]).to eq("4")
    expect(tree[0][:rule][:array_rule][0][:repetition_step]).to eq("2")
    expect(tree[0][:rule][:array_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:array_rule][1][:repetition_min]).to eq("1")
    expect(tree[0][:rule][:array_rule][1][:repetition_max]).to eq(nil)
    expect(tree[0][:rule][:array_rule][1][:repetition_step]).to eq("3")
    expect(tree[0][:rule][:array_rule][2][:target_rule_name][:rule_name]).to eq("my_rule3")
    expect(tree[0][:rule][:array_rule][2][:repetition_min]).to eq(nil)
    expect(tree[0][:rule][:array_rule][2][:repetition_max]).to eq("9")
    expect(tree[0][:rule][:array_rule][2][:repetition_step]).to eq("3")
  end

  it 'should not parse an array rule with rule names ored for one and repetition' do
    expect{ JCR.parse( '$trule = :[ $my_rule1 *1..2, $my_rule2 *1..| $my_rule3 *..3 ]' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should parse an array rule with rule names ored and repetition' do
    tree = JCR.parse( '$trule = :[ $my_rule1 *1..2| $my_rule2 *1..| $my_rule3 *..3]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:array_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:array_rule][0][:repetition_min]).to eq("1")
    expect(tree[0][:rule][:array_rule][0][:repetition_max]).to eq("2")
    expect(tree[0][:rule][:array_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:array_rule][1][:repetition_min]).to eq("1")
    expect(tree[0][:rule][:array_rule][1][:repetition_max]).to eq(nil)
    expect(tree[0][:rule][:array_rule][2][:target_rule_name][:rule_name]).to eq("my_rule3")
    expect(tree[0][:rule][:array_rule][2][:repetition_max]).to eq("3")
  end

  it 'should parse an array rule with rule names and short repetition' do
    tree = JCR.parse( '$trule = :[ $my_rule1 *, $my_rule2 +, $my_rule3 ?, $my_rule4 *4 ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:array_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:array_rule][0][:repetition_min]).to eq(nil)
    expect(tree[0][:rule][:array_rule][0][:repetition_max]).to eq(nil)
    expect(tree[0][:rule][:array_rule][0][:zero_or_more]).to eq('*')
    expect(tree[0][:rule][:array_rule][0][:repetition_step]).to eq(nil)
    expect(tree[0][:rule][:array_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:array_rule][1][:one_or_more]).to eq("+")
    expect(tree[0][:rule][:array_rule][1][:reptition_step]).to eq(nil)
    expect(tree[0][:rule][:array_rule][2][:target_rule_name][:rule_name]).to eq("my_rule3")
    expect(tree[0][:rule][:array_rule][2][:optional]).to eq("?")
    expect(tree[0][:rule][:array_rule][3][:target_rule_name][:rule_name]).to eq("my_rule4")
    expect(tree[0][:rule][:array_rule][3][:specific_repetition]).to eq("4")
  end

  it 'should parse an array rule with rule names and short repetition with steps' do
    tree = JCR.parse( '$trule = :[ $my_rule1 *%3, $my_rule2 +%5, $my_rule3 ?, $my_rule4 *4 ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:array_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:array_rule][0][:repetition_min]).to eq(nil)
    expect(tree[0][:rule][:array_rule][0][:repetition_max]).to eq(nil)
    expect(tree[0][:rule][:array_rule][0][:repetition_step]).to eq('3')
    expect(tree[0][:rule][:array_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:array_rule][1][:one_or_more]).to eq("+")
    expect(tree[0][:rule][:array_rule][1][:repetition_step]).to eq("5")
    expect(tree[0][:rule][:array_rule][2][:target_rule_name][:rule_name]).to eq("my_rule3")
    expect(tree[0][:rule][:array_rule][2][:optional]).to eq("?")
    expect(tree[0][:rule][:array_rule][3][:target_rule_name][:rule_name]).to eq("my_rule4")
    expect(tree[0][:rule][:array_rule][3][:specific_repetition]).to eq("4")
  end

  it 'should not parse an array rule with rule names ored for one and short repetition' do
    expect{ JCR.parse( '$trule = :[ $my_rule1 *, $my_rule2 +| $my_rule3?,$my_rule4*4 ]' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should parse an array rule with an object rule' do
    tree = JCR.parse( '$trule = :[ $my_rule1, { $my_rule2 } ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:array_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:array_rule][1][:object_rule][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an array rule with an object rule and value rule' do
    tree = JCR.parse( '$trule = :[ integer , { $my_rule2 } ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an array rule with a rulename and an array rule' do
    tree = JCR.parse( '$trule = :[ $my_rule1 , [ $my_rule2 ] ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an array rule with a rulename and an array rule with an object rule and value rule' do
    tree = JCR.parse( '$trule = :[ $my_rule1 , [ integer, { $my_rule2 } ] ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an array rule with a rulename and an array rule with an object rule and value rule all ored' do
    tree = JCR.parse( '$trule = :[ $my_rule1 | [ integer | { $my_rule2 } ] ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an array rule with an choice array group' do
    tree = JCR.parse( '$trule = :[ ($my_rule1| $my_rule2 )+]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:array_rule][:group_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:array_rule][:group_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an array rule with an sequence array group' do
    tree = JCR.parse( '$trule = :[ ($my_rule1, $my_rule2 )+]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:array_rule][:group_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:array_rule][:group_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an array rule with a rulename and a group rule' do
    tree = JCR.parse( '$trule = :[ $my_rule1 | ( integer | { $my_rule2 } ) ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an array rule with a rulename and a group rule with count' do
    tree = JCR.parse( '$trule = :[ $my_rule1 | ( integer | { $my_rule2 } )*1..2 ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a rulename only' do
    tree = JCR.parse( '$trule = ( $my_rule1 )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a only a rulename with repetition' do
    tree = JCR.parse( '$trule = ( $my_rule1 *0..15 )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a member rule only' do
    tree = JCR.parse( '$trule = ( "thing" : $target_rule )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a member rule that has a value rule' do
    tree = JCR.parse( '$trule = ( "thing" : integer )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a member rule specified with a regex that has a value rule' do
    tree = JCR.parse( '$trule = ( /.*/ : integer )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a member rule specified with a regex and repetition that has a value rule' do
    tree = JCR.parse( '$trule = ( /.*/ : integer *0..15 )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a member rule specified with a regex and only repetition min that has a value rule' do
    tree = JCR.parse( '$trule = ( /.*/ : integer * 1.. )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with an array rule with an object rule and value rule' do
    tree = JCR.parse( '$trule = ( [ integer, { $my_rule2 } ] )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a rulename and an array rule with an object rule and value rule' do
    tree = JCR.parse( '$trule = ( $my_rule1 , [ integer, { $my_rule2 } ] )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with an optional rulename and an array rule with an object rule and value rule' do
    tree = JCR.parse( '$trule = ( $my_rule1*..1 , [ integer, { $my_rule2 } ] )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with an optional rulename and an optional array rule with an object rule and value rule' do
    tree = JCR.parse( '$trule = ( $my_rule1*0..1 , [ integer, { $my_rule2 } ] *0..1 )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a repitition rulename and an array rule with an object rule and value rule' do
    tree = JCR.parse( '$trule = ( $my_rule1 *1..2, [ integer, { $my_rule2 } ] )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a repitition rulename and a repetition array rule with an object rule and value rule' do
    tree = JCR.parse( '$trule = ( $my_rule1 *1..2 , [ integer, { $my_rule2 } ]*..4 )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a rulename and an array rule with an object rule and value rule and another group' do
    tree = JCR.parse( '$trule = ( $my_rule1 , [ integer, { $my_rule2 } ], ( $my_rule3, $my_rule4 ) )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an object rule with a group rule and a rulename' do
    tree = JCR.parse( '$trule = :{ ( $my_rule1, $my_rule2 ), $my_rule3 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an object rule with an optional group rule and a rulename' do
    tree = JCR.parse( '$trule = :{ ( $my_rule1, $my_rule2 )*0..1, $my_rule3 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an array rule with rule names and repitition and a group rule' do
    tree = JCR.parse( '$trule = :[ $my_rule1 *1..2, ( $my_rule2, $my_rule3 ) ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a value rule with a comment' do
    tree = JCR.parse( "$trule = :/.*/ ;\;;\n" )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a member regex rule with a comment' do
    tree = JCR.parse( "$trule = /.*/ : $target_rule ;\;;\n" )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse two rules on the same line' do
    tree = JCR.parse( '$trule1 = :/.*/  $trule2 = /.*/ : $target_rule' )
    expect(tree[0][:rule][:rule_name]).to eq("trule1")
    expect(tree[1][:rule][:rule_name]).to eq("trule2")
  end

  it 'should parse two rules on the same line without : prefix' do
    tree = JCR.parse( '$trule1 = /.*/  $trule2 = /.*/ : $target_rule' )
    expect(tree[0][:rule][:rule_name]).to eq("trule1")
    expect(tree[1][:rule][:rule_name]).to eq("trule2")
  end

  it 'should parse a top value rule' do
    tree = JCR.parse( '/.*/' )
  end

  it 'should parse a top array rule' do
    tree = JCR.parse( '[ any * ]' )
  end

  it 'should parse two top array rules' do
    JCR.parse( '[ any * ] [ integer *2 ]' )
  end

  it 'should parse two top array rules' do
    JCR.parse( '$trule = "baz":integer [ any * ] [ integer *2 ]' )
  end

  it 'should parse two top array rules' do
    JCR.parse( '[ any * ] $trule = "baz":integer [ integer *2 ]' )
  end

  it 'should parse two top array rules' do
    JCR.parse( '[ any * ] [ integer *2 ] $trule = "baz":integer' )
  end

  it 'should parse a top object rule' do
    tree = JCR.parse( '{ "foo" :any }' )
  end

  it 'should parse two top object rules' do
    tree = JCR.parse( '{ "foo" :any }{ "bar" :any }' )
  end

  it 'should parse two top object rules' do
    tree = JCR.parse( '$trule = "baz":integer { "foo" :integer }{ "bar" :any }' )
  end

  it 'should parse two top object rules' do
    tree = JCR.parse( '{ "foo" :integer }$trule = "baz":integer{ "bar" :any }' )
  end

  it 'should parse two top object rules' do
    tree = JCR.parse( '{"foo":integer}{"bar":any}$trule="baz":integer' )
  end

  it 'should parse multiple comments before any directives' do
    ex = <<EX
;comment 1
;comment 2
;comment 3
;comment 4
#jcr-version 4.0
$trule2 =/.*/ :$target_rule
EX
    tree = JCR.parse( ex )
    expect(tree[1][:rule][:rule_name]).to eq("trule2")
  end

  it 'should parse two rules separated by multiple comment' do
    ex = <<EX
$trule1= type /.*/
;comment 1
;comment 2
;comment 3
;comment 4
$trule2 =/.*/ :$target_rule
EX
    tree = JCR.parse( ex )
    expect(tree[0][:rule][:rule_name]).to eq("trule1")
    expect(tree[1][:rule][:rule_name]).to eq("trule2")
  end

  it 'should parse rules containing multiple comment' do
    ex = <<EX
$trule1
	;comment 1
	;comment 2
	=:
/.*/
$trule2 = /.*/: $target_rule
EX
    tree = JCR.parse( ex )
    expect(tree[0][:rule][:rule_name]).to eq("trule1")
    expect(tree[1][:rule][:rule_name]).to eq("trule2")
  end

  it 'should parse rules, directives, comments and bottom rules' do
    ex = <<EX
[ $trule1 ]
$trule1 = type /.*/
;comment 1
;comment 2
;comment 3
;comment 4
;comment 5
#jcr-version 4.0
EX
    tree = JCR.parse( ex )
  end

  it 'should parse multiple nameless or root rules' do
    ex = <<EX1A
[ 1, 2, 3 ]

[ "foo", "bar", "baz", string ]

{
  "mom": string,
  "applie pie": integer,
  "chevrolet": { "wheels" : 4, "seats": 2, "engine" : "big" }
}
EX1A
    tree = JCR.parse( ex )
  end

  it 'should parse an array rule with rule names and repitition and a group rule with newlines' do
    ex1 = <<EX1
$trule=:[
  $my_rule1 *1..2,
  ( $my_rule2, $my_rule3 )
]
EX1
    tree = JCR.parse( ex1 )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an array rule with rule names and repitition and a group rule with a trailing comment' do
    ex2 = <<EX2
$trule =:[ ;comment 1
  $my_rule1 *1..2, ;comment 2
  ( $my_rule2, $my_rule3 ) ;comment 3
] ;comment 4
EX2
    tree = JCR.parse( ex2 )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse group rules and value groups' do
    ex2a = <<EX2A
$trule =:[ ;comment 1
  $my_rule1 *1..2, ;comment 2
  ( string | integer ),
  ( $my_rule2 | $my_rule3 ) ;comment 3
] ;comment 4
EX2A
    tree = JCR.parse( ex2a )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse group rules and value union that are ored' do
    ex2b = <<EX2B
$trule =:[ ;comment 1
  $my_rule1 *1..2| ;comment 2
  ( string | integer ) |
  ( $my_rule2 , $my_rule3 ) ;comment 3
] ;comment 4
EX2B
    tree = JCR.parse( ex2b )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse multiple commented rules' do
    ex3 = <<EX3
$trule= type [ ;comment 1
  $my_rule1 *1..2, ;comment 2
  ( $my_rule2, $my_rule3 ) ;comment 3
] ;comment 4
$trule2=( $my_rule1 , [ integer, { $my_rule2 } ], ( $my_rule3, $my_rule4 ) )
EX3
    tree = JCR.parse( ex3 )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[1][:rule][:rule_name]).to eq("trule2")
  end

  it 'should parse multiple commented rules with directives' do
    ex4 = <<EX4
# ruleset-id http://arin.net/JCRexamples
# import http://arin.net/otherexamples
$trule = :[ ;comment 1
  $my_rule1 *1..2, ;comment 2
  ( $my_rule2, $my_rule3 ) ;comment 3
] ;comment 4
$trule2= ( $my_rule1 , [ integer, { $my_rule2 } ], ( $my_rule3, $my_rule4 ) )
EX4
    tree = JCR.parse( ex4 )
    expect(tree[2][:rule][:rule_name]).to eq("trule")
    expect(tree[3][:rule][:rule_name]).to eq("trule2")
  end

  it 'should parse multiple commented rules with multiple directives' do
    ex5 = <<EX5
# jcr-version 4.0
# ruleset-id net.arin.eng
# import http://arin.net/otherexamples as otherrules
$trule = :[ ;comment 1
  $my_rule1 *1..2, ;comment 2
  ( $my_rule2, $my_rule3 ) ;comment 3
] ;comment 4
$trule2= ( $my_rule1 , [ integer, { $my_rule2 } ], ( $my_rule3, $my_rule4 ) )
EX5
    tree = JCR.parse( ex5 )
    expect(tree[3][:rule][:rule_name]).to eq("trule")
    expect(tree[4][:rule][:rule_name]).to eq("trule2")
  end

  it 'should parse jcr-version directive major and minor numbers' do
    ex5a = <<EX5a
# jcr-version 4.0
# ruleset-id my_awesome_rules
# import http://arin.net/otherexamples as otherrules
EX5a
    tree = JCR.parse( ex5a )
    expect(tree[0][:directive][:jcr_version_d][:major_version]).to eq("4")
    expect(tree[0][:directive][:jcr_version_d][:minor_version]).to eq("0")
  end

  it 'should parse jcr-version directive major and minor numbers followed by integer root rule' do
    ex5a = <<EX5a
# jcr-version 4.0
integer
string
EX5a
    tree = JCR.parse( ex5a )
    expect(tree[0][:directive][:jcr_version_d][:major_version]).to eq("4")
    expect(tree[0][:directive][:jcr_version_d][:minor_version]).to eq("0")
    expect(tree[1][:primitive_rule][:integer_v]).to eq("integer")
    expect(tree[2][:primitive_rule][:string]).to eq("string")
  end

  it 'should parse jcr-version directive major and minor numbers with 1 extension' do
    ex5a = <<EX5a
# jcr-version 4.0 +foo_1-1.0
# ruleset-id my_awesome_rules
# import http://arin.net/otherexamples as otherrules
EX5a
    tree = JCR.parse( ex5a )
    expect(tree[0][:directive][:jcr_version_d][:major_version]).to eq("4")
    expect(tree[0][:directive][:jcr_version_d][:minor_version]).to eq("0")
  end

  it 'should parse jcr-version directive major and minor numbers with 1 extension with leading space' do
    ex5a = <<EX5a
# jcr-version 4.0 + foo_1
# ruleset-id my_awesome_rules
# import http://arin.net/otherexamples as otherrules
EX5a
    tree = JCR.parse( ex5a )
    expect(tree[0][:directive][:jcr_version_d][:major_version]).to eq("4")
    expect(tree[0][:directive][:jcr_version_d][:minor_version]).to eq("0")
  end

  it 'should parse jcr-version directive major and minor numbers with 2 extensions' do
    ex5a = <<EX5a
# jcr-version 4.0 +foo_1 +bar_4
# ruleset-id my_awesome_rules
# import http://arin.net/otherexamples as otherrules
EX5a
    tree = JCR.parse( ex5a )
    expect(tree[0][:directive][:jcr_version_d][:major_version]).to eq("4")
    expect(tree[0][:directive][:jcr_version_d][:minor_version]).to eq("0")
  end

  it 'should parse jcr-version directive major and minor numbers with 2 extensions with leading space' do
    ex5a = <<EX5a
# jcr-version 4.0 + foo_1 + bar_4
# ruleset-id my_awesome_rules
# import http://arin.net/otherexamples as otherrules
EX5a
    tree = JCR.parse( ex5a )
    expect(tree[0][:directive][:jcr_version_d][:major_version]).to eq("4")
    expect(tree[0][:directive][:jcr_version_d][:minor_version]).to eq("0")
  end

  it 'should parse jcr-version directive major and minor numbers with 2 extensions with leading and trailing two lines' do
    ex5a = %q[
#{ jcr-version 4.0
   + foo_1 + bar_4 }
# ruleset-id my_awesome_rules
# import http://arin.net/otherexamples as otherrules
]
    tree = JCR.parse( ex5a )
    expect(tree[0][:directive][:jcr_version_d][:major_version]).to eq("4")
    expect(tree[0][:directive][:jcr_version_d][:minor_version]).to eq("0")
  end

  it 'should parse jcr-version directive major and minor numbers with comment & 2 extensions with leading and trailing two lines' do
    ex5a = %q[
#{ jcr-version 4.0 ; A comment
   +foo_1 +bar_4 }
# ruleset-id my_awesome_rules
# import http://arin.net/otherexamples as otherrules
]
    tree = JCR.parse( ex5a )
    expect(tree[0][:directive][:jcr_version_d][:major_version]).to eq("4")
    expect(tree[0][:directive][:jcr_version_d][:minor_version]).to eq("0")
  end

  it 'should parse jcr-version directive major and minor numbers with 2 extensions with leading and trailing three lines' do
    ex5a = %q[
#{ jcr-version
   4.0
   + foo_1 + bar_4 }
# ruleset-id my_awesome_rules
# import http://arin.net/otherexamples as otherrules
]
    tree = JCR.parse( ex5a )
    expect(tree[0][:directive][:jcr_version_d][:major_version]).to eq("4")
    expect(tree[0][:directive][:jcr_version_d][:minor_version]).to eq("0")
  end

  it 'should parse multi-line jcr-version directive major and minor numbers with 2 extensions with immediate closing brace' do
    ex = %q[
#{ jcr-version
   4.0
   + foo_1 + bar_4}
]
    tree = JCR.parse( ex )
    expect(tree[0][:directive][:jcr_version_d][:major_version]).to eq("4")
    expect(tree[0][:directive][:jcr_version_d][:minor_version]).to eq("0")
  end

  it 'should parse directives with spaces after them' do
  # Note: ~ characters in JCR below changed to spaces by the gsub() regular expression
    ex5b = <<EX5b
# jcr-version 4.0 ~
# ruleset-id my_awesome_rules~
# import http://arin.net/otherexamples as otherrules ~
EX5b
    tree = JCR.parse( ex5b.gsub( /~/, ' ' ) )
    expect(tree[0][:directive][:jcr_version_d][:major_version]).to eq("4")
    expect(tree[0][:directive][:jcr_version_d][:minor_version]).to eq("0")
  end

  it 'should parse multi-line jcr-version directive major and minor numbers' do
    ex5c = <<'EX5c' # 'EX5c' to prevent #{/...} string interpolation
#{jcr-version
  4.0 }
# ruleset-id my_awesome_rules
# import http://arin.net/otherexamples as otherrules
EX5c
    tree = JCR.parse( ex5c )
    expect(tree[0][:directive][:jcr_version_d][:major_version]).to eq("4")
    expect(tree[0][:directive][:jcr_version_d][:minor_version]).to eq("0")
  end

  it 'should parse multi-line jcr-version directive major and minor numbers with immediate closing brace' do
    ex5c = <<'EX5c' # 'EX5c' to prevent #{/...} string interpolation
#{jcr-version
  4.0}
# ruleset-id my_awesome_rules
# import http://arin.net/otherexamples as otherrules
EX5c
    tree = JCR.parse( ex5c )
    expect(tree[0][:directive][:jcr_version_d][:major_version]).to eq("4")
    expect(tree[0][:directive][:jcr_version_d][:minor_version]).to eq("0")
  end

  it 'should parse multi-line ruleset-id with immediate closing brace' do
    ex = %q[
#{ruleset-id my_awesome_rules}
]
    tree = JCR.parse( ex )
    expect(tree[0][:directive][:ruleset_id_d][:ruleset_id]).to eq("my_awesome_rules")
  end

  it 'should parse multi-line import with immediate closing brace' do
    ex = %q[
#{import my_awesome_rules}
]
    tree = JCR.parse( ex )
    expect(tree[0][:directive][:import_d][:ruleset_id]).to eq("my_awesome_rules")
  end

  it 'should permit parsing multi-line unknown directives' do
    ex5d = <<'EX5d' # 'EX5d' to prevent #{/...} string interpolation
#{constraint foo
  $name }
# ruleset-id my_awesome_rules
# import http://arin.net/otherexamples as otherrules
EX5d
    tree = JCR.parse( ex5d )
  end

  it 'should permit parsing multi-line unknown directives with immediate closing brace' do
    ex5d = <<'EX5d' # 'EX5d' to prevent #{/...} string interpolation
#{constraint foo
  $name}
# ruleset-id my_awesome_rules
# import http://arin.net/otherexamples as otherrules
EX5d
    tree = JCR.parse( ex5d )
  end

  it 'should permit parsing multi-line unknown directives' do
    ex5e = <<'EX5e' # 'EX5e' to prevent #{/...} string interpolation
#{ constraint foo
  $name } ; A comment
# ruleset-id my_awesome_rules
# import http://arin.net/otherexamples as otherrules
EX5e
    tree = JCR.parse( ex5e )
  end

  it 'should permit parsing multi-line unknown directives with early comment' do
    ex5e = <<'EX5e' # 'EX5e' to prevent #{/...} string interpolation
#{ constraint; A comment
  foo
  $name }
# ruleset-id my_awesome_rules
# import http://arin.net/otherexamples as otherrules
EX5e
    tree = JCR.parse( ex5e )
    expect(tree[0][:directive][:directive_name]).to eq("constraint")
  end

  it 'should parse multi-line unknown directives with comment, q_strings and regexs' do
    ex5f = %q[
#{constraint foo
  $name == /p\d{1,5}/ && ; Must allow } and { in comments
  $when == "} with {"
}
# ruleset-id my_awesome_rules
# import http://arin.net/otherexamples as otherrules
    ]
    tree = JCR.parse( ex5f )
  end

  it 'should parse ex1 from I-D' do
    ex6 = <<EX6
$root =: [
    {
        "precision" : string,
        "Latitude" : float,
        "Longitude" : float,
        "Address" : string,
        "City" : string,
        "State" : string,
        "Zip" : string,
        "Country" : string
    }*2..2
]
EX6
    tree = JCR.parse( ex6 )
    expect(tree[0][:rule][:rule_name]).to eq("root")
  end

  it 'should parse ex2 from I-D' do
    ex7 = <<EX7
$width = "width" : 0..1280
$height = "height" : 0..1024

$root =: {
    "Image" : {
        $width, $height, "Title" :string,
        "thumbnail":  { $width, $height, "Url" :uri },
        "IDs": [ integer* ]
    }
}
EX7
    tree = JCR.parse( ex7 )
    expect(tree[2][:rule][:rule_name]).to eq("root")
  end

  it 'should parse ex3 from I-D' do
    ex8 = <<EX8
$nameserver = :{

     ; the host name of the name server
     "name" : fqdn,

     ; the ip addresses of the nameserver
     "ipAddresses" : [ ( ipv4 | ipv6 )* ],

     ; common rules for all structures
     $common
   }
EX8
    tree = JCR.parse( ex8 )
    expect(tree[0][:rule][:rule_name]).to eq("nameserver")
  end

  it 'should parse ex4 from I-D' do
    ex9 = <<EX9
$any_member = /.*/ : any

$object_of_anything =: { $any_member* }
EX9
    tree = JCR.parse( ex9 )
    expect(tree[0][:rule][:rule_name]).to eq("any_member")
  end

  it 'should parse ex5 from I-D' do
    ex10 = <<EX10
$object_of_anything = :{ /.*/:any* }
EX10
    tree = JCR.parse( ex10 )
    expect(tree[0][:rule][:rule_name]).to eq("object_of_anything")
  end

  it 'should parse ex6 from I-D' do
    ex11 = <<EX11
$any_value =: any

$array_of_any = :[ $any_value* ]
EX11
    tree = JCR.parse( ex11 )
    expect(tree[0][:rule][:rule_name]).to eq("any_value")
  end

  it 'should parse ex7 from I-D' do
    ex12 = <<EX12
$array_of_any = :[ any*.. ]
EX12
    tree = JCR.parse( ex12 )
    expect(tree[0][:rule][:rule_name]).to eq("array_of_any")
  end

  it 'should parse groups of values with groups' do
    ex12 = <<EX12
$encodings = :( "base32" | "base64" )
$more_encodings = :( "base32hex" | "base64url" | "base16" )
$all_encodings = :( $encodings | $more_encodings )
EX12
    tree = JCR.parse( ex12 )
    expect(tree[0][:rule][:rule_name]).to eq("encodings")
  end

  it 'should parse groups of values with groups and values with groups with rules' do
    ex12 = <<EX12
$encodings = :( "base32" | "base64" )
$more_encodings = :( "base32hex" | "base64url" | "base16" )
$all_encodings = :( $encodings | $more_encodings )
EX12
    tree = JCR.parse( ex12 )
    expect(tree[0][:rule][:rule_name]).to eq("encodings")
  end

  it 'should parse groups of values' do
    ex12 = <<EX12
$encodings = :( "base32" | "base64" )
$more_encodings = ( "base32hex" | "base64url" | "base16" )
$all_encodings = ( $encodings | $more_encodings )
EX12
    tree = JCR.parse( ex12 )
    expect(tree[0][:rule][:rule_name]).to eq("encodings")
  end

  it 'should parse groups of values and rulenames' do
    ex12 = <<EX12
$encodings = type ( "base32" | "base64" )
$more_encodings = type ( "base32hex" | "base64url" | "base16" )
$all_encodings = type ( "rot13" | $encodings | $more_encodings )
EX12
    tree = JCR.parse( ex12 )
    expect(tree[0][:rule][:rule_name]).to eq("encodings")
  end

  it 'should parse groups of values with namespaced rule names' do
    ex12 = <<EX12
# import http://ietf.org/rfcXXXX.JCR as rfcXXXX
$encodings = :( "base32" | "base64" )
$more_encodings = :( "base32hex" | "base64url" | "base16" )
$all_encodings = :( $rfcXXXX.encodings | $more_encodings )
EX12
    tree = JCR.parse( ex12 )
    expect(tree[3][:rule][:rule_name]).to eq("all_encodings")
    expect(tree[3][:rule][:group_rule][0][:target_rule_name][:ruleset_id_alias]).to eq("rfcXXXX")
    expect(tree[3][:rule][:group_rule][0][:target_rule_name][:rule_name]).to eq("encodings")
  end

  it 'should parse groups of values with non-namespaced rule names' do
    ex12 = <<EX12
# import http://ietf.org/rfcXXXX.JCR as rfcXXXX
$encodings = ( "base32" | "base64" )
$more_encodings = :( "base32hex" | "base64url" | "base16" )
$all_encodings = :( $more_encodings | $rfcXXXX.encodings )
EX12
    tree = JCR.parse( ex12 )
    expect(tree[3][:rule][:rule_name]).to eq("all_encodings")
    expect(tree[3][:rule][:group_rule][0][:target_rule_name][:rule_name]).to eq("more_encodings")
  end

  it 'should parse groups as groups' do
    ex12 = <<EX12
$encodings = :( "base32" | "base64" | integer | /^.{5,10}/ | ipv4 | ipv6 | fqdn )
EX12
    tree = JCR.parse( ex12 )
    expect(tree[0][:rule][:rule_name]).to eq("encodings")
  end

  it 'should error with member with group of two ANDED values' do
    expect{ JCR.parse( '$mrule = "thing" :( integer , float ) ' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should error with member with group of ORed and ANDED values' do
    expect{ JCR.parse( '$mrule = "thing" ( integer | string , float ) ' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should error with 1 member with group of OR values and member with group of AND values' do
    expect{ JCR.parse( '$mrule = "thing" : ( integer | float )  $mrule2 = "thing2" : ( ipv4 , ipv6 )' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should error with member with group of value OR group' do
    expect{ JCR.parse( '$mrule = "thing" : ( integer | ( ipv4 , ipv6 ) ) ' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should error with object with group of value OR value' do
    expect{ JCR.parse( '$arule = :{ ( "m2" :integer | :integer ) }' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should error with object with group of value OR array' do
    expect{ JCR.parse( '$arule = :{ ( "m2" :integer | [ integer ] ) }' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should error with object with group of value OR object' do
    expect{ JCR.parse( '$arule = :{ ( "m2" :integer | { "m1" :integer } ) }' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should error with object with two groups of members and values 2' do
    expect{ JCR.parse( '$rule = :{ ( "m1" :integer | :float ), ( "m3" :string, "m4" :string ) }' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should error with object with two groups of members and values 1' do
    expect{ JCR.parse( '$rule = :{ ( "m1" :integer | "m2" :float ), ( "m3" :string, string ) }' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should error with object with group with member and value' do
    expect{ JCR.parse( '$rule = :{ ( "thing" :integer | integer ) }' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should error with object with group with member and value' do
    expect{ JCR.parse( '$rule = :{ ( "thing" :integer | integer ) }' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should error with array with group of value OR with group with member' do
    expect{ JCR.parse( '$trule = :any  $rule = :[ ( integer | ( ipv4 | "thing" : $trule ) ) ]' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should error with array with group of OR values and array with group of values and member' do
    expect{ JCR.parse( '$trule = :any  $rule = :[ ( integer | float ) ]  $rule2 = :[ ( ipv4 , "thing" : $trule ) ]' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should error with array with value and group of one value and one member' do
    expect{ JCR.parse( '$trule = :any  $rule = :[ string, ( integer, "thing" : $trule ) ]' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should error with array with group of one value and one member' do
    expect{ JCR.parse( '$trule = :any  $rule = :[ ( integer, "thing" : $trule ) ]' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should error with array with group of one member' do
    expect{ JCR.parse( '$trule = :any  $rule = :[ ( "thing" : $trule ) ]' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should error with value with group of value OR group with member' do
    expect{ JCR.parse( '$trule = :any  $rule = :( integer | ( ipv4 | "thing" : $trule ) ) ' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should error with value with group of ORed and ANDED values' do
    expect{ JCR.parse( '$rule = ( integer | string , float )' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should error with integer or float with no range' do
    expect{ JCR.parse( '$my_int = :..' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should parse value rule with {not} annotation directive' do
    tree = JCR.parse( '$my_int = type @{not} 2' )
  end

  it 'should parse value rule with {not} annotation directive' do
    tree = JCR.parse( '$my_int = : @{not} 2' )
  end

  it 'should parse member rule with {not} annotation directive' do
    tree = JCR.parse( '$my_mem = @{not} "count" :integer' )
  end

  it 'should parse object rule with {not} annotation directive' do
    tree = JCR.parse( '$my_rule = : @{not} { "count" :integer }' )
  end

  it 'should parse object rule with {not} annotation directive' do
    tree = JCR.parse( '$my_rule =: @{root} @{not} { "count" :integer }' )
  end

  it 'should parse array rule with {not} annotation directive' do
    tree = JCR.parse( '$my_rule =: @{not} [ integer* ]' )
  end

  it 'should parse array rule with unordered directive' do
    tree = JCR.parse( '$my_rule =: @{unordered} [ integer* ]' )
  end

  it 'should parse array rule with root directive' do
    tree = JCR.parse( '$my_rule =: @{root} [ integer* ]' )
  end

  it 'should parse array rule with unordered directive' do
    tree = JCR.parse( '$my_rule =: @{unordered} @{not} [ integer* ]' )
  end

  it 'should parse array rule with unordered directive' do
    tree = JCR.parse( '$my_rule =: @{not} @{unordered} [ integer* ]' )
  end

  it 'should parse group rule with {not} annotation directive' do
    tree = JCR.parse( '$my_rule = @{ not } ( integer* )' )
  end

  it 'should parse array rule with {not} annotation directive on value rule' do
    tree = JCR.parse( '$my_rule = :[ @{not} integer * ]' )
  end

  it 'should parse array rule with {not} annotation directive on target rule' do
    JCR.parse( '$my_rule = :[ @{not} $target_rule ]' )
  end

  it 'should parse a group rule with a rulename only with {not} annotation' do
    tree = JCR.parse( '$trule = @{not} ( $my_rule1 )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an unknown annotation' do
    tree = JCR.parse( '$my_int =: @{assert $ % 3 == 0} 2' )
    expect(tree[0][:rule][:rule_name]).to eq("my_int")
  end

  it 'should parse an unknown annotation before the rule name' do
    tree = JCR.parse( '@{doc "this is my integer"} $my_int =: 2' )
    expect(tree[0][:rule][:rule_name]).to eq("my_int")
  end

  it 'should parse an unknown annotation with comments, q_string and regexs' do
    tree = JCR.parse( '$my_int =: @{assert $name == /p\d{1,5}/ && ; Must allow } and { in comments
                          $when == "} with {"
                          } 2' )
    expect(tree[0][:rule][:rule_name]).to eq("my_int")
  end

  it 'should parse an array with a literal number' do
    JCR.parse( '$v =: 1' )
  end

  it 'should parse an array with a literal number' do
    JCR.parse( '[ 1 ]' )
  end

  it 'should parse an array with a literal number with repetition of 1' do
    JCR.parse( '[ 1 *1 ]' )
  end

  it 'should parse an array with a literal number with repetition of *1' do
    JCR.parse( '[ 1 *..1 ]' )
  end

  it 'should parse an array with a literal number with repetition of 1*1' do
    JCR.parse( '[ 1 *1..1 ]' )
  end

  it 'should parse an array with a literal number with repetition of 1*' do
    JCR.parse( '[ 1 *1..]' )
  end

  it 'should parse a group with a literal number' do
    JCR.parse( '( 1 )' )
  end

  it 'should parse a group with a literal number with repetition of 1' do
    JCR.parse( '( 1 *1 )' )
  end

  it 'should parse a group with a literal number with repetition of *1' do
    JCR.parse( '( 1 *..1 )' )
  end

  it 'should parse a group with a literal number with repetition of 1*1' do
    JCR.parse( '( 1 *1..1 )' )
  end

  it 'should parse a group with a literal number with repetition of 1*' do
    JCR.parse( '( 1 *1..)' )
  end

  it 'should parse an object with a member literal number' do
    JCR.parse( '{ "n" : 1 }' )
  end

  it 'should parse an object with a member literal number with repetition of 1' do
    JCR.parse( '{ "n" : 1 *1 }' )
  end

  it 'should parse an object rule with an annotated group' do
    tree = JCR.parse( '{ "a" : string , @{not}( "b" : integer, "c" : boolean ) }')
    # produces the following tree
    # [{:object_rule=>
    #       [{:member_rule=>
    #             {:member_name=>{:q_string=>"a"@3},
    #              :primitive_rule=>{:string=>"string"@8}}},
    #        {:sequence_combiner=>","@15,
    #         :group_rule=>
    #             [{:not_annotation=>"not"@19},
    #              {:member_rule=>
    #                   {:member_name=>{:q_string=>"b"@26},
    #                    :primitive_rule=>{:integer_v=>"integer"@31}}},
    #              {:sequence_combiner=>","@38,
    #               :member_rule=>
    #                   {:member_name=>{:q_string=>"c"@41},
    #                    :primitive_rule=>{:boolean_v=>"boolean"@46}}}]}]}]
    expect(tree[0][:object_rule][1][:group_rule][0][:not_annotation]).to_not be_nil
  end

  it 'should parse an object rule with an annotated group and a repetition' do
    tree = JCR.parse( '{ "a" : string , @{not}( "b" : integer, "c" : boolean ) ? }')
    # produces the following tree
    # [{:object_rule=>
    #       [{:member_rule=>
    #             {:member_name=>{:q_string=>"a"@3},
    #              :primitive_rule=>{:string=>"string"@8}}},
    #        {:sequence_combiner=>","@15,
    #         :group_rule=>
    #             [{:not_annotation=>"not"@19},
    #              {:member_rule=>
    #                   {:member_name=>{:q_string=>"b"@26},
    #                    :primitive_rule=>{:integer_v=>"integer"@31}}},
    #              {:sequence_combiner=>","@38,
    #               :member_rule=>
    #                   {:member_name=>{:q_string=>"c"@41},
    #                    :primitive_rule=>{:boolean_v=>"boolean"@46}}}],
    #         :optional=>"?"@56}]}]
    expect(tree[0][:object_rule][1][:group_rule][0][:not_annotation]).to_not be_nil
    expect(tree[0][:object_rule][1][:optional]).to_not be_nil
  end

  it 'should parse an array rule with an annotated group' do
    tree = JCR.parse( '[ string , @{not} ( integer * ) ]')
    # produces the following tree
    # [{:array_rule=>
    #       [{:primitive_rule=>{:string=>"string"@2}},
    #        {:sequence_combiner=>","@9,
    #         :group_rule=>
    #             [{:not_annotation=>"not"@13},
    #              {:primitive_rule=>{:integer_v=>"integer"@20},
    #               :zero_or_more=>"*"@28}]}]}]
    expect(tree[0][:array_rule][1][:group_rule][0][:not_annotation]).to_not be_nil
  end

  it 'should parse an array rule with an annotated group and a repetition' do
    tree = JCR.parse( '[ string , @{not} ( integer * ) ? ]')
    # produces the following tree
    # [{:array_rule=>
    #       [{:primitive_rule=>{:string=>"string"@2}},
    #        {:sequence_combiner=>","@9,
    #         :group_rule=>
    #             [{:not_annotation=>"not"@13},
    #              {:primitive_rule=>{:integer_v=>"integer"@20}, :zero_or_more=>"*"@28}],
    #         :optional=>"?"@32}]}]
    expect(tree[0][:array_rule][1][:group_rule][0][:not_annotation]).to_not be_nil
    expect(tree[0][:array_rule][1][:optional]).to_not be_nil
  end

end