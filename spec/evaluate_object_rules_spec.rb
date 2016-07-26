# Copyright (C) 2015 American Registry for Internet Numbers (ARIN)
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
require 'pp'
require_relative '../lib/jcr/evaluate_object_rules'

describe 'evaluate_object_rules' do

  it 'should fail something that is not an object' do
    tree = JCR.parse( '$trule=: { }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass something that is not an object with {not} annotation' do
    tree = JCR.parse( '$trule=: @{not} { }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an empty object against an empty object rule' do
    tree = JCR.parse( '$trule=type { }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an empty object against an empty {not} annotation object rule' do
    tree = JCR.parse( '$trule=: @{not} { }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a non-empty object against an empty object rule' do
    tree = JCR.parse( '$trule=: { }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { "foo"=>"bar"}, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass a non-empty object against an empty {not} annotation object rule' do
    tree = JCR.parse( '$trule=: @{not} { }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { "foo"=>"bar"}, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an empty object against an object rule with a string member' do
    tree = JCR.parse( '$trule=: { "foo" :string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an empty object against an object rule with a string member and a string member' do
    tree = JCR.parse( '$trule=: { "foo" :string, "bar" :string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an empty object against an object rule with a string member or a string member' do
    tree = JCR.parse( '$trule=: { "foo" :string| "bar" :string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an object with one string against an object rule with a string member and a string member' do
    tree = JCR.parse( '$trule=: { "foo":string, "bar":string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { "foo"=>"thing" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an object with one string against an object rule with a string member or a string member' do
    tree = JCR.parse( '$trule=: { "foo":string | "bar":string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { "foo"=>"thing" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an object with one string against an {not} annotation object rule with a string member or a string member' do
    tree = JCR.parse( '$trule=: @{not} { "foo":string | "bar":string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { "foo"=>"thing" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an object with one string against an object rule with a string member and an integer member' do
    tree = JCR.parse( '$trule=: { "foo":string, "bar":integer }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { "foo"=>"thing" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an object with string and integer against an object rule with a string member and an integer member' do
    tree = JCR.parse( '$trule=: { "foo":string, "bar":integer }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { "foo"=>"thing", "bar"=>2 }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with one string against an object rule with a string member or a integer member' do
    tree = JCR.parse( '$trule=: { "foo":string | "bar":integer }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { "foo"=>"thing" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with string and integer against an object rule with a string member and an integer member or string member' do
    tree = JCR.parse( '$trule=: { "bar":string, ( "foo":integer | "foo":string ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { "bar"=>"thing", "foo"=>2 }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with string and string against an object rule with a string member and an integer member or string member' do
    tree = JCR.parse( '$trule=: { "bar":string, ( "foo":integer | "foo":string ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"bar"=>"thing","foo"=>"thing2" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with two strings against an object rule with string twice' do
    tree = JCR.parse( '$trule=: { /m.*/ :string @2..2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=>"thing","m2"=>"thing2" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with two strings against an object rule with string member once or twice' do
    tree = JCR.parse( '$trule=: { /m.*/:string @1..2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=>"thing","m2"=>"thing2"}, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with two strings against an object rule with string member 1..2 step 2' do
    tree = JCR.parse( '$trule=: { /m.*/:string @1..2%2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=>"thing","m2"=>"thing2"}, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with two strings against an object rule with string member 1..4 step 2' do
    tree = JCR.parse( '$trule=: { /m.*/:string @1..4%2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=>"thing","m2"=>"thing2"}, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an object with two strings against an object rule with string member 1..6 step 3' do
    tree = JCR.parse( '$trule=: { /m.*/:string @1..6%3 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=>"thing","m2"=>"thing2"}, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an object with two strings against an object rule with string member once or twice or thrice' do
    tree = JCR.parse( '$trule=: { /m.*/:string @1..3 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=>"thing","m2"=>"thing2" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with one string against an object rule with string member once or twice' do
    tree = JCR.parse( '$trule=: { /m.*/:string @1..2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=>"thing" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with one string against an object rule with string member default or twice' do
    tree = JCR.parse( '$trule=: { /m.*/:string @..2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=> "thing" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an empty object  against an object rule with string member default or twice' do
    tree = JCR.parse( '$trule=: { /m.*/:string @..2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {}, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with one string against an object rule with string member once or default' do
    tree = JCR.parse( '$trule=: { /m.*/:string @1.. }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=> "thing" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with two strings against an object rule with string member once or default' do
    tree = JCR.parse( '$trule=: { /m.*/:string @1.. }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=> "thing", "m2"=>"thing2" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with two strings against an object rule with string member one or more' do
    tree = JCR.parse( '$trule=: { /m.*/:string @+ }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=> "thing", "m2"=>"thing2" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with a string and integer against an object rule with string member once or twice (ignore extras)' do
    tree = JCR.parse( '$trule=: { /m.*/:string @1..2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=> "thing","m2"=> 2 }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with a string and integer against an object rule with string member default or twice (ignore extras)' do
    tree = JCR.parse( '$trule=: { /m.*/:string @..2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=> "thing", "m2"=>2 }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with a string and integer and string against an object rule with string and integer (ignore extra)' do
    tree = JCR.parse( '$trule=: { "foo":string, "bar":integer }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"foo"=>"thing","bar"=>2,"foo2"=>"thing2" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an object with a string against an object rule with string twice' do
    tree = JCR.parse( '$trule=: { /m.*/:string @2..2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=> "thing" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an object with a string and integer against an object rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( '$trule=: { /s.*/:string @1..2, /i.*/:integer @1..2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing", "i1"=> 2 }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with two strings and integer against an object rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( '$trule=: { /s.*/:string@1..2, /i.*/:integer @1..2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=> "thing2","i1"=> 2 }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with one string and two integer against an object rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( '$trule=: { /s.*/:string @1..2, /i.*/:integer @1..2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","i1"=> 1,"i2"=> 2 }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with two string and two integer against an object rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( '$trule=: { /s.*/:string @1..2, /i.*/:integer @1..2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=> "thing2","i1"=> 1,"i2"=> 2 }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with two strings and two integers against an object rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( '$trule=: { /s.*/:string @1..2, /i.*/:integer @1..2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=> "thing2","i1"=> 1,"i2"=> 2 }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with one string and three integer against an object rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( '$trule=: { /s.*/:string @1..2, /i.*/:integer @1..2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","i1"=> 1,"i2"=> 2,"i3"=> 3 }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with two strings and two integers against an object rule with string 1*2 and any 1*2' do
    tree = JCR.parse( '$trule=: { /s.*/:string @1..2, /.*/:integer @1..2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=> "thing2","1"=> 1,"2"=> 2 }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with two strings and two integers against an object rule with string 2 and any 2' do
    tree = JCR.parse( '$trule=: { /s.*/:string @2, /.*/:integer @2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=> "thing2","1"=> 1,"2"=> 2 }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with two strings and two integers against an object rule with string + and any +' do
    tree = JCR.parse( '$trule=: { /s.*/:string @+, /.*/:integer @+ }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=> "thing2","1"=> 1,"2"=> 2 }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with two strings and two integers against an object rule with string ? and any ?' do
    tree = JCR.parse( '$trule=: { /s.*/:string @?, /.*/:integer @? }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=> "thing2","1"=> 1,"2"=> 2 }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with one strings and one integers against an object rule with string ? and any ?' do
    tree = JCR.parse( '$trule=: { /s.*/:string @?, /.*/:integer @? }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","1"=> 1 }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an object with two members against an object rule with overlapping rules' do
    tree = JCR.parse( '$trule=: { /.*/:any @2, /.*/:any @1 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","1"=> 1 }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should ignore extra members in an object' do
    tree = JCR.parse( '$trule=: { /s.*/:string @2, "foo":integer @1 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=>"thing2","foo"=>2,"bar"=>"baz" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should not ignore extra members in an object' do
    tree = JCR.parse( '$trule=: { /s.*/:string@2, "foo":integer@1, @{not} /.*/:any@+ }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=>"thing2","foo"=>2,"bar"=>"baz" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass object with not extra members using {not} annotation' do
    tree = JCR.parse( '$trule=: { /s.*/:string@2, "foo":integer@1, @{not} /.*/:any @? }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=>"thing2","foo"=>2 }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass object with string member and object member' do
    tree = JCR.parse( '$trule=: { "s1":string, "o1" :{ "ss1":string } }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","o1"=>{"ss1"=>"thing2"} }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass object with a string member and group member containing a string member' do
    tree = JCR.parse( '$trule=: { "s1":string, ( "s2":string ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=>"thing2" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass object with a string member and optional group member containing a string member' do
    tree = JCR.parse( '$trule=: { "s1":string, ( "s2":string ) @? }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass object with a string member and 0..1 group member containing a string member' do
    tree = JCR.parse( '$trule=: { "s1":string, ( "s2":string ) @0..1 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=>"thing2" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass object with a string member and 0..2 group member containing a string member' do
    tree = JCR.parse( '$trule=: { "s1":string, ( "s2":string ) @0..2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=>"thing2" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass object w/ 2 mems against a string member and 0..2 group member containing a string member' do
    tree = JCR.parse( '$trule=: { "s1":string, ( /s[2-9]/:string ) @0..2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=>"thing2" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass object w/ 2 mems against a string member and 1..2 group member containing a string member' do
    tree = JCR.parse( '$trule=: { "s1":string, ( /s[2-9]/:string @1..2 ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=>"thing2" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass object w/ 3 mems against a string member and 0..2 group member containing a string member' do
    tree = JCR.parse( '$trule=: { "s1":string, ( /s[2-9]/:string ) @0..2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=>"thing2","s3"=>"thing3" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass object w/ 3 mems against a string member and 0..3 group member containing a string member' do
    tree = JCR.parse( '$trule=: { "s1":string, ( /s[2-9]/:string ) @0..3 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=>"thing2","s3"=>"thing3" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass object w/ 4 mems against a string member and 0..3 group member containing a string member' do
    tree = JCR.parse( '$trule=: { "s1":string, ( /s[2-9]/:string ) @0..3 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=>"thing2","s3"=>"thing3","s4"=>"thing4" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass object w/ 3 mems against a string member and 0..4%2 group member containing a string member' do
    tree = JCR.parse( '$trule=: { "s1":string, ( /s[2-9]/:string ) @0..4%2 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=>"thing2","s3"=>"thing3" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail object w/ 3 mems against a string member and 0..6%3 group member containing a string member' do
    tree = JCR.parse( '$trule=: { "s1":string, ( /s[2-9]/:string @0..6%3 ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=>"thing2","s3"=>"thing3" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail object w/ 3 mems against a string member and 0..6%3 group member containing a string member', :focus => true do
    tree = JCR.parse( '$trule=: { "s1":string, ( /s[2-9]/:string ) @0..6%3 }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=>"thing2","s3"=>"thing3" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass object with 2 ORed groups of ANDs 1' do
    tree = JCR.parse( '$trule=: { ("s1":string, "s2":string ) | ( "s3":string , "s4":string ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=>"thing2" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass object with 2 ORed groups of ANDs 2' do
    tree = JCR.parse( '$trule=: { ("s1":string, "s2":string ) | ( "s3":string , "s4":string ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s3"=> "thing","s4"=>"thing2" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail object with 2 ORed groups of ANDs 2' do
    tree = JCR.parse( '$trule=: { ("s1":string, "s2":string ) | ( "s3":string , "s4":string ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s5"=> "thing","s6"=>"thing2" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass object with simple nested groups' do
    tree = JCR.parse( '$trule=: { ( ("s1":string, "s2":string ) ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=>"thing2" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass object with complex nested groups 1' do
    tree = JCR.parse( '$trule=: { ( ( "s1":string, "s2":string ) | ( "s3":string ) ) , "s4":string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=>"foo", "s2"=> "thing","s4"=>"thing2" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass object with complex nested groups 2' do
    tree = JCR.parse( '$trule=: { ( ( "s1":string, "s2":string ) | ( "s3":string ) ) , "s4":string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s3"=>"fuzz", "s4"=>"thing2" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail object with complex nested groups 1' do
    tree = JCR.parse( '$trule=: { ( ( "s1":string, "s2":string ) | ( "s3":string ) ) , "s4":string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s0"=>"fizz", "s4"=>"thing2" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass object with complex nested groups with a named rule 1' do
    tree = JCR.parse( '$orule =: { ( $trule | ( "s3":string ) ) , "s4":string }  $trule = ( "s1":string, "s2":string )' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=>"foo", "s2"=> "thing","s4"=>"thing2" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass object with ORed groups of overlapping member rules 1' do
    tree = JCR.parse( '$orule =: { ( $a, $b ) | ( $a, $c ) | ( $b, $c ) }'\
                      '$a = "a":string $b = "b":string $c = "c":string')
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"a"=>"a", "b"=> "b" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass object with ORed groups of overlapping member rules 2' do
    tree = JCR.parse( '$orule =: { ( $a, $b ) | ( $a, $c ) | ( $b, $c ) }'\
                      '$a = "a":string $b = "b":string $c = "c":string')
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"a"=>"a", "c"=> "c" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass object with ORed groups of overlapping member rules 3' do
    tree = JCR.parse( '$orule =: { ( $a, $b ) | ( $a, $c ) | ( $b, $c ) }'\
                      '$a = "a":string $b = "b":string $c = "c":string')
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"b"=>"b", "c"=> "c" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail object with ORed groups of overlapping member rules 3' do
    tree = JCR.parse( '$orule =: { ( $a, $b ) | ( $a, $c ) | ( $b, $c ) }'\
                      '$a = "a":string $b = "b":string $c = "c":string')
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"b"=>"b", "d"=> "d" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass object with ORed groups with manditory member but optional if another exists 1' do
    tree = JCR.parse( '$orule =: { ( $a, $b ) | ( $a, $b@?, $c ) }'\
                      '$a = "a":string $b = "b":string $c = "c":string')
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"a"=>"a", "b"=> "b" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail object with ORed groups with manditory member but optional if another exists 1' do
    tree = JCR.parse( '$orule =: { ( $a, $b ) | ( $a, $b@?, $c ) }'\
                      '$a = "a":string $b = "b":string $c = "c":string')
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"a"=>"a" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass object with ORed groups with manditory member but optional if another exists 2' do
    tree = JCR.parse( '$orule =: { ( $a, $b ) | ( $a, $b@?, $c ) }'\
                      '$a = "a":string $b = "b":string $c = "c":string')
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"a"=>"a", "c"=> "c" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass object with ORed groups with manditory member but optional if another exists 3' do
    tree = JCR.parse( '$orule =: { ( $a, $b ) | ( $a, $b@?, $c ) }'\
                      '$a = "a":string $b = "b":string $c = "c":string')
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"a"=>"a", "b"=>"b", "c"=> "c" }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass a restricted object' do
    tree = JCR.parse( '$orule = { "foo" : 1, "bar" : 2, @{not} // : any @+ }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"foo"=>1, "bar"=> 2 }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an unrestricted object' do
    tree = JCR.parse( '$orule = { "foo" : 1, "bar" : 2, @{not} // : any @+ }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"foo"=>1, "bar"=> 2, "baz" => 3 }, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

end
