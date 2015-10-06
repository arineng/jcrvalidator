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
require_relative '../lib/JCR/evaluate_object_rules'

describe 'evaluate_object_rules' do

  it 'should fail something that is not an object' do
    tree = JCR.parse( 'trule { }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, mapping )
    expect( e.success ).to be_falsey
  end

  it 'should pass an empty object against an empty object rule' do
    tree = JCR.parse( 'trule { }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { }, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should fail a non-empty object against an empty object rule' do
    tree = JCR.parse( 'trule { }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { "foo"=>"bar"}, mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an empty object against an object rule with a string member' do
    tree = JCR.parse( 'trule { "foo" :string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { }, mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an empty object against an object rule with a string member and a string member' do
    tree = JCR.parse( 'trule { "foo" :string, "bar" :string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { }, mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an empty object against an object rule with a string member or a string member' do
    tree = JCR.parse( 'trule { "foo" :string| "bar" :string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { }, mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an object with one string against an object rule with a string member and a string member' do
    tree = JCR.parse( 'trule { "foo":string, "bar":string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { "foo"=>"thing" }, mapping )
    expect( e.success ).to be_falsey
  end

  it 'should pass an object with one string against an object rule with a string member or a string member' do
    tree = JCR.parse( 'trule { "foo":string | "bar":string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { "foo"=>"thing" }, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should fail an object with one string against an object rule with a string member and an integer member' do
    tree = JCR.parse( 'trule { "foo":string, "bar":integer }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { "foo"=>"thing" }, mapping )
    expect( e.success ).to be_falsey
  end

  it 'should pass an object with string and integer against an object rule with a string member and an integer member' do
    tree = JCR.parse( 'trule { "foo":string, "bar":integer }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { "foo"=>"thing", "bar"=>2 }, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with one string against an object rule with a string member or a integer member' do
    tree = JCR.parse( 'trule { "foo":string | "bar":integer }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { "foo"=>"thing" }, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with string and integer against an object rule with a string member and an integer member or string member' do
    tree = JCR.parse( 'trule { "bar":string, "foo":integer | "foo":string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], { "bar"=>"thing", "foo"=>2 }, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with string and string against an object rule with a string member and an integer member or string member' do
    tree = JCR.parse( 'trule { "bar":string, "foo":integer | "foo":string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"bar"=>"thing","foo"=>"thing2" }, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with two strings against an object rule with string twice' do
    tree = JCR.parse( 'trule { 2*2 /m.*/ :string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=>"thing","m2"=>"thing2" }, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with two strings against an object rule with string member once or twice' do
    tree = JCR.parse( 'trule { 1*2 /m.*/:string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=>"thing","m2"=>"thing2"}, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with two strings against an object rule with string member once or twice or thrice' do
    tree = JCR.parse( 'trule { 1*3 /m.*/:string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=>"thing","m2"=>"thing2" }, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with one string against an object rule with string member once or twice' do
    tree = JCR.parse( 'trule { 1*2 /m.*/:string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=>"thing" }, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with one string against an object rule with string member default or twice' do
    tree = JCR.parse( 'trule { *2 /m.*/:string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=> "thing" }, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an empty object  against an object rule with string member default or twice' do
    tree = JCR.parse( 'trule { *2 /m.*/:string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {}, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with one string against an object rule with string member once or default' do
    tree = JCR.parse( 'trule { 1* /m.*/:string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=> "thing" }, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with two strings against an object rule with string member once or default' do
    tree = JCR.parse( 'trule { 1* /m.*/:string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=> "thing", "m2"=>"thing2" }, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should fail an object with a string and integer against an object rule with string member once or twice' do
    tree = JCR.parse( 'trule { 1*2 /m.*/:string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=> "thing","m2"=> 2 }, mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an object with a string and integer against an object rule with string member default or twice' do
    tree = JCR.parse( 'trule { *2 /m.*/:string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=> "thing", "m2"=>2 }, mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an object with a string and integer and string against an object rule with string and integer' do
    tree = JCR.parse( 'trule { "foo":string, "bar":integer }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"foo"=>"thing","bar"=>2,"foo2"=>"thing2" }, mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an object with a string against an object rule with string twice' do
    tree = JCR.parse( 'trule { 2*2 /m.*/:string }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"m1"=> "thing" }, mapping )
    expect( e.success ).to be_falsey
  end

  it 'should pass an object with a string and integer against an object rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( 'trule { 1*2 /s.*/:string, 1*2 /i.*/:integer }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing", "i1"=> 2 }, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with two strings and integer against an object rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( 'trule { 1*2 /s.*/:string, 1*2 /i.*/:integer }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=> "thing2","i1"=> 2 }, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with one string and two integer against an object rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( 'trule { 1*2 /s.*/:string, 1*2 /i.*/:integer }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","i1"=> 1,"i2"=> 2 }, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with two string and two integer against an object rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( 'trule { 1*2 /s.*/:string, 1*2 /i.*/:integer }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=> "thing2","i1"=> 1,"i2"=> 2 }, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an object with two strings and two integers against an object rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( 'trule { 1*2 /s.*/:string, 1*2 /i.*/:integer }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=> "thing2","i1"=> 1,"i2"=> 2 }, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should fail an object with one string and three integer against an object rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( 'trule { 1*2 /s.*/:string, 1*2 /i.*/:integer }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","i1"=> 1,"i2"=> 2,"i3"=> 3 }, mapping )
    expect( e.success ).to be_falsey
  end

  it 'should pass an object with two strings and two integers against an object rule with string 1*2 and any 1*2' do
    tree = JCR.parse( 'trule { 1*2 /s.*/:string, 1*2 /.*/:integer }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"s1"=> "thing","s2"=> "thing2","1"=> 1,"2"=> 2 }, mapping )
    expect( e.success ).to be_truthy
  end

end
