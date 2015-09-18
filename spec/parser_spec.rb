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
require 'rspec'
require_relative '../jcrvalidator'
require 'pp'

describe 'parser' do

=begin
  an example of printing out the ascii_tree

  it 'should parse an ip4 value defintion 1' do
    begin
      tree = JCRValidator.parse( 'trule : ip4' )
        expect(tree[0][:rule][:rule_name]).to eq("trule")
        expect(tree[0][:rule][:value_rule][:ip4]).to eq("ip4")
      rescue Parslet::ParseFailed => failure

        puts failure.cause.ascii_tree
      end
  end
=end

  it 'should parse an ip4 value defintion 1' do
    tree = JCRValidator.parse( 'trule : ip4' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:value_rule][:ip4]).to eq("ip4")
  end
  it 'should parse an ip4 value defintion 2' do
    tree = JCRValidator.parse( 'trule :ip4' )
    expect(tree[0][:rule][:value_rule][:ip4]).to eq("ip4")
  end
  it 'should parse an ip4 value defintion 3' do
    tree = JCRValidator.parse( 'trule : ip4 ' )
    expect(tree[0][:rule][:value_rule][:ip4]).to eq("ip4")
  end

  it 'should parse an ip6 value defintion 1' do
    tree = JCRValidator.parse( 'trule : ip6' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:value_rule][:ip6]).to eq("ip6")
  end
  it 'should parse an ip6 value defintion 2' do
    tree = JCRValidator.parse( 'trule :ip6' )
    expect(tree[0][:rule][:value_rule][:ip6]).to eq("ip6")
  end
  it 'should parse an ip6 value defintion 3' do
    tree = JCRValidator.parse( 'trule : ip6 ' )
    expect(tree[0][:rule][:value_rule][:ip6]).to eq("ip6")
  end

  it 'should parse a string constant' do
    tree = JCRValidator.parse( 'trule : "a string constant"' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:value_rule][:q_string]).to eq("a string constant")
  end

  it 'should parse a string' do
    tree = JCRValidator.parse( 'trule : string' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:value_rule][:string]).to eq("string")
  end

  it 'should parse a regex 1' do
    tree = JCRValidator.parse( 'trule : /a.regex.goes.here.*/' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:value_rule][:regex]).to eq("a.regex.goes.here.*")
  end
  it 'should parse a regex 2' do
    tree = JCRValidator.parse( 'trule : /a.regex\\.goes.here.*/' )
    expect(tree[0][:rule][:value_rule][:regex]).to eq("a.regex\\.goes.here.*")
  end

  it 'should parse a uri' do
    tree = JCRValidator.parse( 'trule : uri' )
    expect(tree[0][:rule][:value_rule][:uri]).to eq("uri")
  end

  it 'should parse a uri template' do
    tree = JCRValidator.parse( 'trule : {scheme}://example.com/{path}' )
    expect(tree[0][:rule][:value_rule][:uri_template]).to eq("{scheme}://example.com/{path}")
  end

  it 'should parse a uri template 2' do
    tree = JCRValidator.parse( 'trule : http://example.com/{path}' )
    expect(tree[0][:rule][:value_rule][:uri_template]).to eq("http://example.com/{path}")
  end

  it 'should parse an any' do
    tree = JCRValidator.parse( 'trule : any' )
    expect(tree[0][:rule][:value_rule][:any]).to eq("any")
  end

  it 'should parse true' do
    tree = JCRValidator.parse( 'trule : true' )
    expect(tree[0][:rule][:value_rule][:true_v]).to eq("true")
  end

  it 'should parse false' do
    tree = JCRValidator.parse( 'trule : false' )
    expect(tree[0][:rule][:value_rule][:false_v]).to eq("false")
  end

  it 'should parse boolean' do
    tree = JCRValidator.parse( 'trule : boolean' )
    expect(tree[0][:rule][:value_rule][:boolean_v]).to eq("boolean")
  end

  it 'should parse null' do
    tree = JCRValidator.parse( 'trule : null' )
    expect(tree[0][:rule][:value_rule][:null]).to eq("null")
  end

  it 'should parse a integer value without a range' do
    tree = JCRValidator.parse( 'trule : integer' )
    expect(tree[0][:rule][:value_rule][:integer_v]).to eq("integer")
  end

  it 'should parse a integer constant' do
    tree = JCRValidator.parse( 'trule : 2' )
    expect(tree[0][:rule][:value_rule][:integer]).to eq("2")
  end

  it 'should parse an integer full range' do
    tree = JCRValidator.parse( 'trule : 0..100' )
    expect(tree[0][:rule][:value_rule][:integer_min]).to eq("0")
    expect(tree[0][:rule][:value_rule][:integer_max]).to eq("100")
  end

  it 'should parse an integer range with a min range' do
    tree = JCRValidator.parse( 'trule : 0..' )
    expect(tree[0][:rule][:value_rule][:integer_min]).to eq("0")
  end

  it 'should parse an integer rangge with a max range' do
    tree = JCRValidator.parse( 'trule : ..100' )
    expect(tree[0][:rule][:value_rule][:integer_max]).to eq("100")
  end

  it 'should parse a float value' do
    tree = JCRValidator.parse( 'trule : float' )
    expect(tree[0][:rule][:value_rule][:float_v]).to eq("float")
  end

  it 'should parse a float constant' do
    tree = JCRValidator.parse( 'trule : 2.0' )
    expect(tree[0][:rule][:value_rule][:float]).to eq("2.0")
  end

  it 'should parse a float range with a full range' do
    tree = JCRValidator.parse( 'trule : 0.0..100.0' )
    expect(tree[0][:rule][:value_rule][:float_min]).to eq("0.0")
    expect(tree[0][:rule][:value_rule][:float_max]).to eq("100.0")
  end

  it 'should parse a float range with a min range' do
    tree = JCRValidator.parse( 'trule : 0.3939..' )
    expect(tree[0][:rule][:value_rule][:float_min]).to eq("0.3939")
  end

  it 'should parse a float range with a max range' do
    tree = JCRValidator.parse( 'trule : ..100.003' )
    expect(tree[0][:rule][:value_rule][:float_max]).to eq("100.003")
  end

  it 'should parse an union 1' do
    tree = JCRValidator.parse( 'trule : ( 1.0 | 2 | true | "yes" | "Y" )' )
    expect(tree[0][:rule][:value_rule][0][:float]).to eq("1.0")
    expect(tree[0][:rule][:value_rule][1][:integer]).to eq("2")
    expect(tree[0][:rule][:value_rule][2][:true_v]).to eq("true")
    expect(tree[0][:rule][:value_rule][3][:q_string]).to eq("yes")
    expect(tree[0][:rule][:value_rule][4][:q_string]).to eq("Y")
  end

  it 'should parse an union 2' do
    tree = JCRValidator.parse( 'trule : ( "no" | false | 1.0 | 2 | true | "yes" | "Y" )' )
    expect(tree[0][:rule][:value_rule][0][:q_string]).to eq("no")
    expect(tree[0][:rule][:value_rule][1][:false_v]).to eq("false")
    expect(tree[0][:rule][:value_rule][2][:float]).to eq("1.0")
    expect(tree[0][:rule][:value_rule][3][:integer]).to eq("2")
    expect(tree[0][:rule][:value_rule][4][:true_v]).to eq("true")
    expect(tree[0][:rule][:value_rule][5][:q_string]).to eq("yes")
    expect(tree[0][:rule][:value_rule][6][:q_string]).to eq("Y")
  end

  it 'should parse an union 3' do
    tree = JCRValidator.parse( 'trule : ( null | "no" | false | 1.0 | 2 | true | "yes" | "Y" )' )
    expect(tree[0][:rule][:value_rule][0][:null]).to eq("null")
    expect(tree[0][:rule][:value_rule][1][:q_string]).to eq("no")
    expect(tree[0][:rule][:value_rule][2][:false_v]).to eq("false")
    expect(tree[0][:rule][:value_rule][3][:float]).to eq("1.0")
    expect(tree[0][:rule][:value_rule][4][:integer]).to eq("2")
    expect(tree[0][:rule][:value_rule][5][:true_v]).to eq("true")
    expect(tree[0][:rule][:value_rule][6][:q_string]).to eq("yes")
    expect(tree[0][:rule][:value_rule][7][:q_string]).to eq("Y")
  end

  it 'should parse a member rule with float range with a max range 3' do
    tree = JCRValidator.parse( 'trule "thing" : ..100.003' )
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:value_rule][:float_max]).to eq("100.003")
  end

  it 'should parse a member rule with integer value' do
    tree = JCRValidator.parse( 'trule "thing" : integer' )
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:value_rule][:integer_v]).to eq("integer")
  end

  it 'should not parse a repetition member string rule with integer value' do
    expect{ tree = JCRValidator.parse( 'trule 1*2 "thing" : integer' ) }.to raise_error
  end

  it 'should parse an any member rule with integer value' do
    tree = JCRValidator.parse( 'trule /.*/ : integer' )
    expect(tree[0][:rule][:member_rule][:member_regex][:regex]).to eq(".*")
    expect(tree[0][:rule][:member_rule][:value_rule][:integer_v]).to eq("integer")
  end

  it 'should parse an regex member rule with string value' do
    tree = JCRValidator.parse( 'trule /a.regex\\.goes.here.*/ : string' )
    expect(tree[0][:rule][:member_rule][:member_regex][:regex]).to eq("a.regex\\.goes.here.*")
    expect(tree[0][:rule][:member_rule][:value_rule][:string]).to eq("string")
  end

  it 'should parse a member rule with an email value 2' do
    tree = JCRValidator.parse( 'trule "thing" : email' )
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:value_rule][:email]).to eq("email")
  end

  it 'should parse a member rule with integer range with a max range 1' do
    tree = JCRValidator.parse( 'trule "thing" : ..100' )
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:value_rule][:integer_max]).to eq("100")
  end

  it 'should parse a member rule with a rule name' do
    tree = JCRValidator.parse( 'trule "thing" my_value_rule' )
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:target_rule_name][:rule_name]).to eq("my_value_rule")
  end

  it 'should parse an object rule with rule names' do
    tree = JCRValidator.parse( 'trule { my_rule1, my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with rule names or`ed' do
    tree = JCRValidator.parse( 'trule { my_rule1 | my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with embeded member rules with names 1' do
    tree = JCRValidator.parse( 'trule { "thing" my_value_rule, my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:target_rule_name][:rule_name]).to eq("my_value_rule")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with embeded member rules with names or`ed`' do
    tree = JCRValidator.parse( 'trule { "thing" my_value_rule| my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:target_rule_name][:rule_name]).to eq("my_value_rule")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with embeded member rules with value rule 1' do
    tree = JCRValidator.parse( 'trule { "thing" : ..100.003, my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:value_rule][:float_max]).to eq("100.003")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with rule name, embeded member rules with value, rule name' do
    tree = JCRValidator.parse( 'trule { my_rule1, "thing" : ..100.003, my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][1][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:object_rule][1][:member_rule][:value_rule][:float_max]).to eq("100.003")
    expect(tree[0][:rule][:object_rule][2][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse a member rule as an object rule with rule name, embeded member rules with value, rule name' do
    tree = JCRValidator.parse( 'trule "mem_rule" { my_rule1, "thing" : ..100.003, my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("mem_rule")
    expect(tree[0][:rule][:member_rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:member_rule][:object_rule][1][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:object_rule][1][:member_rule][:value_rule][:float_max]).to eq("100.003")
    expect(tree[0][:rule][:member_rule][:object_rule][2][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with embeded member rules with value rule ored' do
    tree = JCRValidator.parse( 'trule { "thing" : ..100.003| my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:value_rule][:float_max]).to eq("100.003")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with embeded member rules with value rule spelled out 1' do
    tree = JCRValidator.parse( 'trule { "thing" : ..100.003, my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:value_rule][:float_max]).to eq("100.003")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with rule names with optionality 1' do
    tree = JCRValidator.parse( 'trule { my_rule1, *1 my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:object_rule][1][:repetition_min]).to eq([])
    expect(tree[0][:rule][:object_rule][1][:repetition_max]).to eq("1")
  end

  it 'should parse an object rule with rule names with optionality 2' do
    tree = JCRValidator.parse( 'trule { *1my_rule1, *1 my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][0][:repetition_min]).to eq([])
    expect(tree[0][:rule][:object_rule][0][:repetition_max]).to eq("1")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:object_rule][1][:repetition_min]).to eq([])
    expect(tree[0][:rule][:object_rule][1][:repetition_max]).to eq("1")
  end

  it 'should parse an object rule with rule names with optionality with or' do
    tree = JCRValidator.parse( 'trule { *1my_rule1| *1 my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][0][:repetition_min]).to eq([])
    expect(tree[0][:rule][:object_rule][0][:repetition_max]).to eq("1")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:object_rule][1][:repetition_min]).to eq([])
    expect(tree[0][:rule][:object_rule][1][:repetition_max]).to eq("1")
  end

  it 'should parse an object rule with embeded member rules with value rule with optionality 1' do
    tree = JCRValidator.parse( 'trule { 0*1 "thing" : ..100.003, my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:object_rule][0][:repetition_min]).to eq("0")
    expect(tree[0][:rule][:object_rule][0][:repetition_max]).to eq("1")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:value_rule][:float_max]).to eq("100.003")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with rule names with optionality for any rules' do
    tree = JCRValidator.parse( 'trule { my_rule1, 1*2 my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an array rule with rule names 1' do
    tree = JCRValidator.parse( 'trule [ my_rule1, my_rule2 ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:array_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:array_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an array rule with rule names ored' do
    tree = JCRValidator.parse( 'trule [ my_rule1| my_rule2 ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:array_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:array_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an array rule with rule names and repetition' do
    tree = JCRValidator.parse( 'trule [ 1*2 my_rule1, 1* my_rule2, *3 my_rule3 ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:array_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:array_rule][0][:repetition_min]).to eq("1")
    expect(tree[0][:rule][:array_rule][0][:repetition_max]).to eq("2")
    expect(tree[0][:rule][:array_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:array_rule][1][:repetition_min]).to eq("1")
    expect(tree[0][:rule][:array_rule][1][:repetition_max]).to eq("")
    expect(tree[0][:rule][:array_rule][2][:target_rule_name][:rule_name]).to eq("my_rule3")
    expect(tree[0][:rule][:array_rule][2][:repetition_max]).to eq("3")
  end

  it 'should parse an array rule with rule names ored for one and repetition' do
    tree = JCRValidator.parse( 'trule [ 1*2 my_rule1, 1* my_rule2| *3 my_rule3 ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:array_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:array_rule][0][:repetition_min]).to eq("1")
    expect(tree[0][:rule][:array_rule][0][:repetition_max]).to eq("2")
    expect(tree[0][:rule][:array_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:array_rule][1][:repetition_min]).to eq("1")
    expect(tree[0][:rule][:array_rule][1][:repetition_max]).to eq("")
    expect(tree[0][:rule][:array_rule][2][:target_rule_name][:rule_name]).to eq("my_rule3")
    expect(tree[0][:rule][:array_rule][2][:repetition_max]).to eq("3")
  end

  it 'should parse an array rule with rule names ored and repetition' do
    tree = JCRValidator.parse( 'trule [ 1*2 my_rule1| 1* my_rule2| *3 my_rule3 ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:array_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:array_rule][0][:repetition_min]).to eq("1")
    expect(tree[0][:rule][:array_rule][0][:repetition_max]).to eq("2")
    expect(tree[0][:rule][:array_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:array_rule][1][:repetition_min]).to eq("1")
    expect(tree[0][:rule][:array_rule][1][:repetition_max]).to eq("")
    expect(tree[0][:rule][:array_rule][2][:target_rule_name][:rule_name]).to eq("my_rule3")
    expect(tree[0][:rule][:array_rule][2][:repetition_max]).to eq("3")
  end

  it 'should parse an array rule with an object rule' do
    tree = JCRValidator.parse( 'trule [ my_rule1, { my_rule2 } ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:array_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:array_rule][1][:object_rule][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an array rule with an object rule and value rule' do
    tree = JCRValidator.parse( 'trule [ : integer , { my_rule2 } ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an array rule with a rulename and an array rule' do
    tree = JCRValidator.parse( 'trule [ my_rule1 , [ my_rule2 ] ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an array rule with a rulename and an array rule with an object rule and value rule' do
    tree = JCRValidator.parse( 'trule [ my_rule1 , [ : integer, { my_rule2 } ] ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an array rule with a rulename and an array rule with an object rule and value rule all ored' do
    tree = JCRValidator.parse( 'trule [ my_rule1 | [ : integer | { my_rule2 } ] ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an array rule with a rulename and a group rule' do
    tree = JCRValidator.parse( 'trule [ my_rule1 | ( : integer | { my_rule2 } ) ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an array rule with a rulename and a group rule with count' do
    tree = JCRValidator.parse( 'trule [ my_rule1 | 1*2( : integer | { my_rule2 } ) ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a rulename only' do
    tree = JCRValidator.parse( 'trule ( my_rule1 )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a only a rulename with repetition' do
    tree = JCRValidator.parse( 'trule ( 0*15 my_rule1 )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a member rule only' do
    tree = JCRValidator.parse( 'trule ( "thing" target_rule )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a member rule that has a value rule' do
    tree = JCRValidator.parse( 'trule ( "thing" : integer )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a member rule specified with a regex that has a value rule' do
    tree = JCRValidator.parse( 'trule ( /.*/ : integer )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a member rule specified with a regex and repetition that has a value rule' do
    tree = JCRValidator.parse( 'trule ( 0 * 15 /.*/ : integer )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a member rule specified with a regex and only repetition max that has a value rule' do
    tree = JCRValidator.parse( 'trule ( * 15 /.*/ : integer )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a member rule specified with a regex and only repetition min that has a value rule' do
    tree = JCRValidator.parse( 'trule ( 1 * /.*/ : integer )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with an array rule with an object rule and value rule' do
    tree = JCRValidator.parse( 'trule ( [ : integer, { my_rule2 } ] )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a rulename and an array rule with an object rule and value rule' do
    tree = JCRValidator.parse( 'trule ( my_rule1 , [ : integer, { my_rule2 } ] )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with an optional rulename and an array rule with an object rule and value rule' do
    tree = JCRValidator.parse( 'trule ( *1my_rule1 , [ : integer, { my_rule2 } ] )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with an optional rulename and an optional array rule with an object rule and value rule' do
    tree = JCRValidator.parse( 'trule ( 0*1my_rule1 , 0*1 [ : integer, { my_rule2 } ] )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a repitition rulename and an array rule with an object rule and value rule' do
    tree = JCRValidator.parse( 'trule ( 1*2 my_rule1 , [ : integer, { my_rule2 } ] )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a repitition rulename and a repetition array rule with an object rule and value rule' do
    tree = JCRValidator.parse( 'trule ( 1*2 my_rule1 , *4[ : integer, { my_rule2 } ] )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with a rulename and an array rule with an object rule and value rule and another group' do
    tree = JCRValidator.parse( 'trule ( my_rule1 , [ : integer, { my_rule2 } ], ( my_rule3, my_rule4 ) )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an object rule with a group rule and a rulename' do
    tree = JCRValidator.parse( 'trule { ( my_rule1, my_rule2 ), my_rule3 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an object rule with an optional group rule and a rulename' do
    tree = JCRValidator.parse( 'trule { 0*1( my_rule1, my_rule2 ), my_rule3 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an array rule with rule names and repitition and a group rule' do
    tree = JCRValidator.parse( 'trule [ 1*2 my_rule1, ( my_rule2, my_rule3 ) ]' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an array rule with rule names and repitition and a group rule with newlines' do
    ex1 = <<EX1
trule [
  1*2 my_rule1,
  ( my_rule2, my_rule3 )
]
EX1
    tree = JCRValidator.parse( ex1 )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse an array rule with rule names and repitition and a group rule with a trailing comment' do
    ex2 = <<EX2
trule [ ;comment 1
  1*2 my_rule1, ;comment 2
  ( my_rule2, my_rule3 ) ;comment 3
] ;comment 4
EX2
    tree = JCRValidator.parse( ex2 )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse group rules and value union' do
    ex2a = <<EX2A
trule [ ;comment 1
  1*2 my_rule1, ;comment 2
  : ( string | integer ),
  ( my_rule2 | my_rule3 ) ;comment 3
] ;comment 4
EX2A
    tree = JCRValidator.parse( ex2a )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse group rules and value union that are ored' do
    ex2b = <<EX2B
trule [ ;comment 1
  1*2 my_rule1, ;comment 2
  : ( string | integer ) |
  ( my_rule2 | my_rule3 ) ;comment 3
] ;comment 4
EX2B
    tree = JCRValidator.parse( ex2b )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse multiple commented rules' do
    ex3 = <<EX3
trule [ ;comment 1
  1*2 my_rule1, ;comment 2
  ( my_rule2, my_rule3 ) ;comment 3
] ;comment 4
trule2( my_rule1 , [ : integer, { my_rule2 } ], ( my_rule3, my_rule4 ) )
EX3
    tree = JCRValidator.parse( ex3 )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[1][:rule][:rule_name]).to eq("trule2")
  end

  it 'should parse multiple commented rules with directives' do
    ex4 = <<EX4
# include file://blahbalh ; a collection of rules
trule [ ;comment 1
  1*2 my_rule1, ;comment 2
  ( my_rule2, my_rule3 ) ;comment 3
] ;comment 4
trule2( my_rule1 , [ : integer, { my_rule2 } ], ( my_rule3, my_rule4 ) )
EX4
    tree = JCRValidator.parse( ex4 )
    expect(tree[1][:rule][:rule_name]).to eq("trule")
    expect(tree[2][:rule][:rule_name]).to eq("trule2")
  end

  it 'should parse multiple commented rules with multiple directives' do
    ex5 = <<EX5
# jcr-version 4.0
# ruleset-id http://arin.net/jcrexamples
# include file://blahbalh ; a collection of rules
# pedantic
trule [ ;comment 1
  1*2 my_rule1, ;comment 2
  ( my_rule2, my_rule3 ) ;comment 3
] ;comment 4
trule2( my_rule1 , [ : integer, { my_rule2 } ], ( my_rule3, my_rule4 ) )
EX5
    tree = JCRValidator.parse( ex5 )
    expect(tree[4][:rule][:rule_name]).to eq("trule")
    expect(tree[5][:rule][:rule_name]).to eq("trule2")
  end

  it 'should parse ex1 from I-D' do
    ex6 = <<EX6
root [
    2*2{
        "precision" : string,
        "Latitude" : float,
        "Longitude" : float,
        "Address" : string,
        "City" : string,
        "State" : string,
        "Zip" : string,
        "Country" : string
    }
]
EX6
    tree = JCRValidator.parse( ex6 )
    expect(tree[0][:rule][:rule_name]).to eq("root")
  end

  it 'should parse ex2 from I-D' do
    ex7 = <<EX7
width "width" : 0..1280
height "height" : 0..1024

root {
    "Image" {
        width, height, "Title" :string,
        "thumbnail" { width, height, "Url" :uri },
        "IDs" [ *:integer ]
    }
}
EX7
    tree = JCRValidator.parse( ex7 )
    expect(tree[2][:rule][:rule_name]).to eq("root")
  end

  it 'should parse ex3 from I-D' do
    ex8 = <<EX8
nameserver {

     ; the host name of the name server
     "name" : fqdn,

     ; the ip addresses of the nameserver
     "ipAddresses" [ *( :ip4 | :ip6 ) ],

     common
   }
EX8
    tree = JCRValidator.parse( ex8 )
    expect(tree[0][:rule][:rule_name]).to eq("nameserver")
  end

  it 'should parse ex4 from I-D' do
    ex9 = <<EX9
any_member /.*/ : any

object_of_anything { *any_member }
EX9
    tree = JCRValidator.parse( ex9 )
    expect(tree[0][:rule][:rule_name]).to eq("any_member")
  end

  it 'should parse ex5 from I-D' do
    ex10 = <<EX10
object_of_anything { */.*/:any }
EX10
    tree = JCRValidator.parse( ex10 )
    expect(tree[0][:rule][:rule_name]).to eq("object_of_anything")
  end

  it 'should parse ex6 from I-D' do
    ex11 = <<EX11
any_value : any

array_of_any [ *any_value ]
EX11
    tree = JCRValidator.parse( ex11 )
    expect(tree[0][:rule][:rule_name]).to eq("any_value")
  end

  it 'should parse ex7 from I-D' do
    ex12 = <<EX12
array_of_any [ *:any ]
EX12
    tree = JCRValidator.parse( ex12 )
    expect(tree[0][:rule][:rule_name]).to eq("array_of_any")
  end

  it 'should parse groups of union' do
    ex12 = <<EX12
encodings : ( "base32" | "base64" )
more_encodings : ( "base32hex" | "base64url" | "base16" )
all_encodings ( encodings | more_encodings )
EX12
    tree = JCRValidator.parse( ex12 )
    expect(tree[0][:rule][:rule_name]).to eq("encodings")
  end

  it 'should parse union as unions' do
    ex12 = <<EX12
encodings : ( "base32" | "base64" | integer | /^.{5,10}/ | ip4 | ip6 | fqdn )
EX12
    tree = JCRValidator.parse( ex12 )
    expect(tree[0][:rule][:rule_name]).to eq("encodings")
  end

end