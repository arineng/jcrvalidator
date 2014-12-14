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

  it 'should parse a string without a regex' do
    tree = JCRValidator.parse( 'trule : string' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:value_rule][:string]).to eq("string")
  end

  it 'should parse a string with a regex 1' do
    tree = JCRValidator.parse( 'trule : string /a.regex.goes.here.*/' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:value_rule][:string]).to eq("string")
    expect(tree[0][:rule][:value_rule][:regex]).to eq("a.regex.goes.here.*")
  end
  it 'should parse a string with a regex 2' do
    tree = JCRValidator.parse( 'trule : string /a.regex\\.goes.here.*/' )
    expect(tree[0][:rule][:value_rule][:regex]).to eq("a.regex\\.goes.here.*")
  end

  it 'should parse a uri without a uri template' do
    tree = JCRValidator.parse( 'trule : uri' )
    expect(tree[0][:rule][:value_rule][:uri]).to eq("uri")
  end

  it 'should parse a uri with a uri template' do
    tree = JCRValidator.parse( 'trule : uri http://example.com/{path}' )
    expect(tree[0][:rule][:value_rule][:uri]).to eq("uri")
    expect(tree[0][:rule][:value_rule][:uri_template]).to eq("http://example.com/{path}")
  end

  it 'should parse an any' do
    tree = JCRValidator.parse( 'trule : any' )
    expect(tree[0][:rule][:value_rule][:any]).to eq("any")
  end

  it 'should parse a integer value without a range' do
    tree = JCRValidator.parse( 'trule : integer' )
    expect(tree[0][:rule][:value_rule][:integer_v]).to eq("integer")
  end

  it 'should parse a integer value with a full range' do
    tree = JCRValidator.parse( 'trule : integer 0..100' )
    expect(tree[0][:rule][:value_rule][:integer_v]).to eq("integer")
    expect(tree[0][:rule][:value_rule][:min]).to eq("0")
    expect(tree[0][:rule][:value_rule][:max]).to eq("100")
  end

  it 'should parse a integer value with a min range' do
    tree = JCRValidator.parse( 'trule : integer 0..' )
    expect(tree[0][:rule][:value_rule][:integer_v]).to eq("integer")
    expect(tree[0][:rule][:value_rule][:min]).to eq("0")
  end

  it 'should parse a integer value with a max range' do
    tree = JCRValidator.parse( 'trule : integer ..100' )
    expect(tree[0][:rule][:value_rule][:integer_v]).to eq("integer")
    expect(tree[0][:rule][:value_rule][:max]).to eq("100")
  end

  it 'should parse a float value with a full range' do
    tree = JCRValidator.parse( 'trule : float 0.0..100.0' )
    expect(tree[0][:rule][:value_rule][:float_v]).to eq("float")
    expect(tree[0][:rule][:value_rule][:min]).to eq("0.0")
    expect(tree[0][:rule][:value_rule][:max]).to eq("100.0")
  end

  it 'should parse a float value with a min range' do
    tree = JCRValidator.parse( 'trule : float 0.3939..' )
    expect(tree[0][:rule][:value_rule][:float_v]).to eq("float")
    expect(tree[0][:rule][:value_rule][:min]).to eq("0.3939")
  end

  it 'should parse a float value with a max range' do
    tree = JCRValidator.parse( 'trule : float ..100.003' )
    expect(tree[0][:rule][:value_rule][:float_v]).to eq("float")
    expect(tree[0][:rule][:value_rule][:max]).to eq("100.003")
  end

  it 'should parse an enumeration 1' do
    tree = JCRValidator.parse( 'trule : < 1.0 2 true "yes" "Y" >' )
    expect(tree[0][:rule][:value_rule][:enumeration][0][:float]).to eq("1.0")
    expect(tree[0][:rule][:value_rule][:enumeration][1][:integer]).to eq("2")
    expect(tree[0][:rule][:value_rule][:enumeration][2][:boolean]).to eq("true")
    expect(tree[0][:rule][:value_rule][:enumeration][3][:q_string]).to eq("yes")
    expect(tree[0][:rule][:value_rule][:enumeration][4][:q_string]).to eq("Y")
  end
  it 'should parse an enumeration 2' do
    tree = JCRValidator.parse( 'trule : < "no" false 1.0 2 true "yes" "Y" >' )
    expect(tree[0][:rule][:value_rule][:enumeration][0][:q_string]).to eq("no")
    expect(tree[0][:rule][:value_rule][:enumeration][1][:boolean]).to eq("false")
    expect(tree[0][:rule][:value_rule][:enumeration][2][:float]).to eq("1.0")
    expect(tree[0][:rule][:value_rule][:enumeration][3][:integer]).to eq("2")
    expect(tree[0][:rule][:value_rule][:enumeration][4][:boolean]).to eq("true")
    expect(tree[0][:rule][:value_rule][:enumeration][5][:q_string]).to eq("yes")
    expect(tree[0][:rule][:value_rule][:enumeration][6][:q_string]).to eq("Y")
  end
  it 'should parse an enumeration 3' do
    tree = JCRValidator.parse( 'trule : < null "no" false 1.0 2 true "yes" "Y" >' )
    expect(tree[0][:rule][:value_rule][:enumeration][0][:null]).to eq("null")
    expect(tree[0][:rule][:value_rule][:enumeration][1][:q_string]).to eq("no")
    expect(tree[0][:rule][:value_rule][:enumeration][2][:boolean]).to eq("false")
    expect(tree[0][:rule][:value_rule][:enumeration][3][:float]).to eq("1.0")
    expect(tree[0][:rule][:value_rule][:enumeration][4][:integer]).to eq("2")
    expect(tree[0][:rule][:value_rule][:enumeration][5][:boolean]).to eq("true")
    expect(tree[0][:rule][:value_rule][:enumeration][6][:q_string]).to eq("yes")
    expect(tree[0][:rule][:value_rule][:enumeration][7][:q_string]).to eq("Y")
  end

  it 'should parse a member rule with float value with a max range 3' do
    tree = JCRValidator.parse( 'trule "thing" : float ..100.003' )
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:value_rule][:float_v]).to eq("float")
    expect(tree[0][:rule][:member_rule][:value_rule][:max]).to eq("100.003")
  end

  it 'should parse a member rule with integer value' do
    tree = JCRValidator.parse( 'trule "thing" : integer' )
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:value_rule][:integer_v]).to eq("integer")
  end

  it 'should parse an any member rule with integer value' do
    tree = JCRValidator.parse( 'trule ^"" : integer' )
    expect(tree[0][:rule][:member_rule][:any_member]).to eq("^")
    expect(tree[0][:rule][:member_rule][:value_rule][:integer_v]).to eq("integer")
  end

  it 'should parse a member rule with an email value 2' do
    tree = JCRValidator.parse( 'trule "thing" : email' )
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:value_rule][:email]).to eq("email")
  end

  it 'should parse a member rule with integer value with a max range 1' do
    tree = JCRValidator.parse( 'trule "thing" : integer ..100' )
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:value_rule][:integer_v]).to eq("integer")
    expect(tree[0][:rule][:member_rule][:value_rule][:max]).to eq("100")
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
    tree = JCRValidator.parse( 'trule { "thing" : float ..100.003, my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:value_rule][:float_v]).to eq("float")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:value_rule][:max]).to eq("100.003")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with rule name, embeded member rules with value, rule name' do
    tree = JCRValidator.parse( 'trule { my_rule1, "thing" : float ..100.003, my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][1][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:object_rule][1][:member_rule][:value_rule][:float_v]).to eq("float")
    expect(tree[0][:rule][:object_rule][1][:member_rule][:value_rule][:max]).to eq("100.003")
    expect(tree[0][:rule][:object_rule][2][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse a member rule as an object rule with rule name, embeded member rules with value, rule name' do
    tree = JCRValidator.parse( 'trule "mem_rule" { my_rule1, "thing" : float ..100.003, my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:member_rule][:member_name][:q_string]).to eq("mem_rule")
    expect(tree[0][:rule][:member_rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:member_rule][:object_rule][1][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:member_rule][:object_rule][1][:member_rule][:value_rule][:float_v]).to eq("float")
    expect(tree[0][:rule][:member_rule][:object_rule][1][:member_rule][:value_rule][:max]).to eq("100.003")
    expect(tree[0][:rule][:member_rule][:object_rule][2][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with embeded member rules with value rule ored' do
    tree = JCRValidator.parse( 'trule { "thing" : float ..100.003| my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:value_rule][:float_v]).to eq("float")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:value_rule][:max]).to eq("100.003")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with embeded member rules with value rule spelled out 1' do
    tree = JCRValidator.parse( 'trule { "thing" : float ..100.003, my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:value_rule][:float_v]).to eq("float")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:value_rule][:max]).to eq("100.003")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
  end

  it 'should parse an object rule with rule names with optionality 1' do
    tree = JCRValidator.parse( 'trule { my_rule1, ? my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:object_rule][1][:member_optional]).to eq("?")
  end

  it 'should parse an object rule with rule names with optionality 2' do
    tree = JCRValidator.parse( 'trule { ?my_rule1, ? my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][0][:member_optional]).to eq("?")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:object_rule][1][:member_optional]).to eq("?")
  end

  it 'should parse an object rule with rule names with optionality with or' do
    tree = JCRValidator.parse( 'trule { ?my_rule1| ? my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:target_rule_name][:rule_name]).to eq("my_rule1")
    expect(tree[0][:rule][:object_rule][0][:member_optional]).to eq("?")
    expect(tree[0][:rule][:object_rule][1][:target_rule_name][:rule_name]).to eq("my_rule2")
    expect(tree[0][:rule][:object_rule][1][:member_optional]).to eq("?")
  end

  it 'should parse an object rule with embeded member rules with value rule with optionality 1' do
    tree = JCRValidator.parse( 'trule { ? "thing" : float ..100.003, my_rule2 }' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:member_name][:q_string]).to eq("thing")
    expect(tree[0][:rule][:object_rule][0][:member_optional]).to eq("?")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:value_rule][:float_v]).to eq("float")
    expect(tree[0][:rule][:object_rule][0][:member_rule][:value_rule][:max]).to eq("100.003")
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

  it 'should parse a group rule with a rulename and an array rule with an object rule and value rule' do
    tree = JCRValidator.parse( 'trule ( my_rule1 , [ : integer, { my_rule2 } ] )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with an optional rulename and an array rule with an object rule and value rule' do
    tree = JCRValidator.parse( 'trule ( ?my_rule1 , [ : integer, { my_rule2 } ] )' )
    expect(tree[0][:rule][:rule_name]).to eq("trule")
  end

  it 'should parse a group rule with an optional rulename and an optional array rule with an object rule and value rule' do
    tree = JCRValidator.parse( 'trule ( ?my_rule1 , ? [ : integer, { my_rule2 } ] )' )
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
    tree = JCRValidator.parse( 'trule { ?( my_rule1, my_rule2 ), my_rule3 }' )
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
# include file://blahbalh ; a collection of rules
# pedantic
trule [ ;comment 1
  1*2 my_rule1, ;comment 2
  ( my_rule2, my_rule3 ) ;comment 3
] ;comment 4
trule2( my_rule1 , [ : integer, { my_rule2 } ], ( my_rule3, my_rule4 ) )
EX5
    tree = JCRValidator.parse( ex5 )
    expect(tree[2][:rule][:rule_name]).to eq("trule")
    expect(tree[3][:rule][:rule_name]).to eq("trule2")
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
width "width" : integer 0..1280
height "height" : integer 0..1024

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
any_member ^"" : any

object_of_anything { *any_member }
EX9
    tree = JCRValidator.parse( ex9 )
    expect(tree[0][:rule][:rule_name]).to eq("any_member")
  end

  it 'should parse ex5 from I-D' do
    ex10 = <<EX10
object_of_anything { *^"":any }
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
end