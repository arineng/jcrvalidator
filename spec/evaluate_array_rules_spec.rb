# Copyright (C) 2015-2016 American Registry for Internet Numbers (ARIN)
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
require_relative '../lib/jcr/evaluate_array_rules'

describe 'evaluate_array_rules' do

  it 'should fail something that is not an array' do
    tree = JCR.parse( '$trule =: [ ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass something that is not an array with {not} annotation' do
    tree = JCR.parse( '$trule =: @{not} [ ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an empty array against an empty array rule' do
    tree = JCR.parse( '$trule =: [ ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an empty {not} annotation array against an empty array rule' do
    tree = JCR.parse( '$trule =: @{not} [ ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a non-empty array against an empty array rule' do
    tree = JCR.parse( '$trule =: [ ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass a non-empty array against an empty {not} annotation array rule' do
    tree = JCR.parse( '$trule =: @{not} [ ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an empty array against an array rule with a string' do
    tree = JCR.parse( '$trule =: [ string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an empty array against an array rule with a string and a string' do
    tree = JCR.parse( '$trule =: [ string, string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an empty array against an array rule with a string or a string' do
    tree = JCR.parse( '$trule =: [ string| string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with one string against an array rule with a string and a string' do
    tree = JCR.parse( '$trule =: [ string, string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an array with one string against an array rule with a string or a string' do
    tree = JCR.parse( '$trule =: [ string | integer ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an array with one string against an {not} annotation array rule with a string or a string' do
    tree = JCR.parse( '$trule =: @{not} [ string | integer ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with one string against an array rule with a string and an integer' do
    tree = JCR.parse( '$trule =: [ string, integer ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an array with string and integer against an array rule with a string and an integer' do
    tree = JCR.parse( '$trule =: [ string, integer ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with one string against an array rule with a string or a integer' do
    tree = JCR.parse( '$trule =: [ string | integer ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with string and integer against an array rule with a string and an integer or string' do
    tree = JCR.parse( '$trule =: [ string, ( integer | string ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with string and string against an array rule with a string and an integer or string' do
    tree = JCR.parse( '$trule =: [ string, ( integer | string ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings against an array rule with string twice' do
    tree = JCR.parse( '$trule =: [ string *2..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings against an array rule with string once or twice' do
    tree = JCR.parse( '$trule =: [ string *1..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings against an array rule with string once or twice or thrice' do
    tree = JCR.parse( '$trule =: [ string *1..3 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with three strings against an array rule with string 1..4 % 2' do
    tree = JCR.parse( '$trule =: [ string *1..4%2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", "thing3" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an array with two strings against an array rule with string 1..4 % 2' do
    tree = JCR.parse( '$trule =: [ string *1..4%2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an array with one string against an array rule with string once or twice' do
    tree = JCR.parse( '$trule =: [ string *1..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with one string against an array rule with string default or twice' do
    tree = JCR.parse( '$trule =: [ string *..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings against an array rule with ..4%2' do
    tree = JCR.parse( '$trule =: [ string *..4%2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing1" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an array with three strings against an array rule with ..4%2' do
    tree = JCR.parse( '$trule =: [ string *..4%2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing1", "thing3" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an empty array against an array rule with string default or twice' do
    tree = JCR.parse( '$trule =: [ string *..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with one string against an array rule with string once or default' do
    tree = JCR.parse( '$trule =: [ string *1..]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings against an array rule with string once or default' do
    tree = JCR.parse( '$trule =: [ string *1.. ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with three strings against an array rule with string 1..%2' do
    tree = JCR.parse( '$trule =: [ string *1..%2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", "thing3" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an array with two strings against an array rule with string 1..%2' do
    tree = JCR.parse( '$trule =: [ string *1..%2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an array with two strings against an array rule with string +' do
    tree = JCR.parse( '$trule =: [ string + ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with three strings against an array rule with string + step 2' do
    tree = JCR.parse( '$trule =: [ string +%2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", "thing3" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an array with two strings against an array rule with string + step 3' do
    tree = JCR.parse( '$trule =: [ string +%3 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with a string and integer against an array rule with string once or twice' do
    tree = JCR.parse( '$trule =: [ string *1..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with three strings against an array rule with string once or twice' do
    tree = JCR.parse( '$trule =: [ string *1..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing1", "thing2" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with three strings against an array rule with string zero or twice' do
    tree = JCR.parse( '$trule =: [ string *0..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing1", "thing2" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with five strings against an array rule with string zero or twice' do
    tree = JCR.parse( '$trule =: [ string *0..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing1", "thing2", "thing3", "thing4" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with three strings against an array rule with string twice' do
    tree = JCR.parse( '$trule =: [ string *2..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing1", "thing2" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with two strings and integer against an array rule with string twice' do
    tree = JCR.parse( '$trule =: [ string *2..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing1", 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with a string and integer against an array rule with string default or twice' do
    tree = JCR.parse( '$trule =: [ string *..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with a string and integer and string against an array rule with string and integer' do
    tree = JCR.parse( '$trule =: [ string, integer ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", 2, "thing2" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with a string against an array rule with string twice' do
    tree = JCR.parse( '$trule =: [ string *2..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an array with a string and integer against an array rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( '$trule =: [ string *1..2, integer *1..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings and integer against an array rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( '$trule =: [ string *1..2, integer *1..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with one string and two integer against an array rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( '$trule =: [ string *1..2, integer *1..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", 1, 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two string and two integer against an array rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( '$trule =: [ string *1..2, integer *1..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", 1, 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings and two integers against an array rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( '$trule =: [ string *1..2, integer *1..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", 1, 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an array with one string and three integer against an array rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( '$trule =: [ string *1..2, integer *1..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", 1, 2, 3 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an array with two strings and two integers against an array rule with string 1*2 and any 1*2' do
    tree = JCR.parse( '$trule =: [ string *1..2, any *1..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", 1, 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings and two integers against an array rule with string * and any *' do
    tree = JCR.parse( '$trule =: [ string *, any * ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", 1, 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings and two integers against an array rule with string * step 2 and any * step 2' do
    tree = JCR.parse( '$trule =: [ string *%2, any *%2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", 1, 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an array with two strings and two integers against an array rule with string * step 3 and any * step 3' do
    tree = JCR.parse( '$trule =: [ string *%3, any *%3 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", 1, 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an array with two strings and two arrays against an array rule with string 1*2 and any 1*2' do
    tree = JCR.parse( '$trule =: [ string *1..2, any *1..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", [ 1, 2 ], [ 2, 3 ] ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings and two arrays against an array rule with string 2 and any 2' do
    tree = JCR.parse( '$trule =: [ string *2, any *2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", [ 1, 2 ], [ 2, 3 ] ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an array with one string and one arrays against an array rule with string 2 and any 2' do
    tree = JCR.parse( '$trule =: [ string *2, any *2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", [ 1, 2 ] ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an array with one string and one arrays against an {not} annotation array rule with string 2 and any 2' do
    tree = JCR.parse( '$trule =: @{not} [ string *2, any *2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", [ 1, 2 ] ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings and two arrays against an unordered array rule with string 2 and any 2' do
    tree = JCR.parse( '$trule =: @{unordered} [ string *2, any *2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", [ 1, 2 ], [ 2, 3 ] ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings and two arrays against an unordered array rule with string 2 and group any' do
    tree = JCR.parse( '$trule =: @{unordered} [ string *2, (any,any) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", [ 1, 2 ], [ 2, 3 ] ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings and two arrays against an unordered array rule with string 2 and named group any' do
    tree = JCR.parse( '$trule =: @{unordered} [ string*2, $grule ]  $grule = (any,any)' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", [ 1, 2 ], [ 2, 3 ] ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings and two arrays against an unordered array rule with string 2 and 2 named group any' do
    tree = JCR.parse( '$trule =: @{unordered} [ string*2, $grule *2 ]  $grule = (any)' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", [ 1, 2 ], [ 2, 3 ] ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings and two arrays against an unordered array rule with string 1..2 and 1..2 named group any' do
    tree = JCR.parse( '$trule =: @{unordered} [ string*1..2, $grule *1..2 ]  $grule = (any)' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", [ 1, 2 ], [ 2, 3 ] ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings and two arrays against an unordered array rule with string 0..2 step 2 and 0..2 step 2 named group any' do
    tree = JCR.parse( '$trule =: @{unordered} [ string*0..2%2, $grule *0..2%2 ]  $grule = (any)' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", [ 1, 2 ], [ 2, 3 ] ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an array with two strings and two arrays against an unordered array rule with string 1..2 step 3 and 1..2 step 3 named group any' do
    tree = JCR.parse( '$trule =: @{unordered} [ string*1..2%3, $grule *1..2%3 ]  $grule = (any)' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", [ 1, 2 ], [ 2, 3 ] ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with two strings and two arrays against an unordered array rule with string 0..3 step 2 and 0..3 step 2 named group any' do
    tree = JCR.parse( '$trule =: @{unordered} [ string*0..3%2, $grule *0..3%2 ]  $grule = (any)' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", "thing3", [ 1, 2 ], [ 2, 3 ], [ 4, 5 ] ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with two strings and three arrays against an unordered array rule with string 2 and 2 named group any' do
    tree = JCR.parse( '$trule =: @{unordered} [ string*2, $grule*2 ]  $grule = (any)' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", [ 1, 2 ], [ 2, 3 ], [ 4, 5 ] ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an array with two strings and two integers against an unordered array rule with string 1..2 and integer 1..2' do
    tree = JCR.parse( '$trule =: @{unordered} [ string*1..2, integer*1..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, "thing", "thing2"  ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings and two integers against an unordered array rule with string 1..3 and integer 1..3' do
    tree = JCR.parse( '$trule =: @{unordered} [ string*1..3, integer*1..3 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, "thing", "thing2"  ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings and two integers against an unordered array rule with string 0..3 step 2 and integer 0..3 step 2' do
    tree = JCR.parse( '$trule =: @{unordered} [ string*0..3%2, integer*0..3%2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, "thing", "thing2"  ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an array with two strings and two integers against an unordered array rule with string 1..6 step 3 and integer 1..6 step 3' do
    tree = JCR.parse( '$trule =: @{unordered} [ string*1..6%3, integer*1..6%3 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, "thing", "thing2"  ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an array with two strings and two integers against an unordered array rule with string ..2 and integer ..2' do
    tree = JCR.parse( '$trule =: @{unordered} [ string*..2, integer*..2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, "thing", "thing2"  ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings and two integers against an unordered array rule with string + and integer +' do
    tree = JCR.parse( '$trule =: @{unordered} [ string+, integer+ ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, "thing", "thing2"  ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings and two integers against an unordered array rule with string * and integer *' do
    tree = JCR.parse( '$trule =: @{unordered} [ string*, integer* ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, "thing", "thing2"  ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings and two integers against an unordered array rule with string 2 and any 2' do
    tree = JCR.parse( '$trule =: @{unordered} [ string*2, integer*2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, "thing", "thing2"  ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an array with two strings and two arrays against an {not} annotation, unordered array rule with string 2 and any 2' do
    tree = JCR.parse( '$trule =: @{not} @{unordered} [ string*2, integer*2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, "thing", "thing2"  ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail even with extra elements in an array' do
    tree = JCR.parse( '$trule =: [ string*2, integer*2, any* ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, "thing", "thing2", 23.0, 99.2  ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass even with extra elements in an array' do
    tree = JCR.parse( '$trule =: [ string *2, integer *2, any* ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", 1, 2, 23.0, 99.2  ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass with 2 string and a group of two integers' do
    tree = JCR.parse( '$trule =: [ string *2, $grule *2 ]  $grule = ( integer) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", 1, 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail with 2 string and a group of two integers and extra integer' do
    tree = JCR.parse( '$trule =: [ string *2, $grule *2 ]  $grule = ( integer) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", 1, 2, 3 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass with 2 string and a group of integer and string' do
    tree = JCR.parse( '$trule =: [ string *2, $grule ]  $grule = ( integer, string ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", 1, "thing3" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass with ORed group each with string and repeated integer 1' do
    tree = JCR.parse( '$arule =: [ ( "a", [ integer *2 ] ) | ( "b", [ integer *4 ] ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "a", [ 1, 2 ] ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail with ORed group each with string and repeated integer 1' do
    tree = JCR.parse( '$arule =: [ ( "a", [ integer *2 ] ) | ( "b", [ integer *4 ] ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "a", [ 1, 2, 3, 4 ] ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass with ORed group each with string and repeated integer 2' do
    tree = JCR.parse( '$arule =: [ ( "a", [ integer *2 ] ) | ( "b", [ integer *4 ] ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "b", [ 1, 2, 3, 4 ] ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail with ORed group each with string and repeated integer 2' do
    tree = JCR.parse( '$arule =: [ ( "a", [ integer *2 ] ) | ( "b", [ integer *4 ] ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "b", [ 1, 2 ] ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass with three ANDs and an OR 1' do
    tree = JCR.parse( '$arule =: [ 1, 2, ( 3 | 4 ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 3 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass with three ANDs and an OR 2' do
    tree = JCR.parse( '$arule =: [ 1, 2, ( 3 | 4 ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 4 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail with three ANDs and an OR' do
    tree = JCR.parse( '$arule =: [ 1, 2, ( 3 | 4 ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 4 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass with three ANDs in a group and an OR 1' do
    tree = JCR.parse( '$arule =: [ ( 1, 2, 3 ) | 4 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 3 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass with three ANDs  in a group and an OR 2' do
    tree = JCR.parse( '$arule =: [ ( 1, 2, 3 ) | 4 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 4 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail with three ANDs in a group and an OR' do
    tree = JCR.parse( '$arule =: [ ( 1, 2, 3 ) | 4 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 4 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass unordered with three ANDs in a group and an OR 1' do
    tree = JCR.parse( '$arule =: @{unordered} [ ( 1, 2, 3 ) | 4 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 3, 2, 1 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass unordered with three ANDs  in a group and an OR 2' do
    tree = JCR.parse( '$arule =: @{unordered} [ ( 1, 2, 3 ) | 4 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 4 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail unordered with three ANDs in a group and an OR' do
    tree = JCR.parse( '$arule =: [ ( 1, 2, 3 ) | 4 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 4, 2, 1 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should demonstrate OR and AND logic 1' do
    tree = JCR.parse( '$arule =: [ 1, 2, ( 3 | 4 ) , 5 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect( JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 3 ], JCR::EvalConditions.new( mapping, nil ) ).success ).to be_falsey
    expect( JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 3, 5 ], JCR::EvalConditions.new( mapping, nil ) ).success ).to be_truthy
    expect( JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 4, 5 ], JCR::EvalConditions.new( mapping, nil ) ).success ).to be_truthy
  end

  it 'should demonstrate OR and AND logic 2' do
    tree = JCR.parse( '$arule =: [ 1, 2, ( 3 | 4 | 5 ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect( JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 3 ], JCR::EvalConditions.new( mapping, nil ) ).success ).to be_truthy
    expect( JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 4 ], JCR::EvalConditions.new( mapping, nil ) ).success ).to be_truthy
    expect( JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 5 ], JCR::EvalConditions.new( mapping, nil ) ).success ).to be_truthy
    expect( JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 3, 5 ], JCR::EvalConditions.new( mapping, nil ) ).success ).to be_falsey
  end

  it 'should demonstrate OR and AND logic 3' do
    tree = JCR.parse( '$arule =: [ 1, 2, ( 3 | 4 ), (5 | 6 ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect( JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 3, 5 ], JCR::EvalConditions.new( mapping, nil ) ).success ).to be_truthy
    expect( JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 4, 6 ], JCR::EvalConditions.new( mapping, nil ) ).success ).to be_truthy
    expect( JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 4, 5 ], JCR::EvalConditions.new( mapping, nil ) ).success ).to be_truthy
    expect( JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 3, 6 ], JCR::EvalConditions.new( mapping, nil ) ).success ).to be_truthy
  end

  it 'should demonstrate OR and AND logic 4' do
    tree = JCR.parse( '$arule =: [ 1, 2,( 3 | 4 ), 5, ( 6 | 7 ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect( JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 3, 5, 6 ], JCR::EvalConditions.new( mapping, nil ) ).success ).to be_truthy
    expect( JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 3, 5, 7 ], JCR::EvalConditions.new( mapping, nil ) ).success ).to be_truthy
    expect( JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 4, 5, 6 ], JCR::EvalConditions.new( mapping, nil ) ).success ).to be_truthy
    expect( JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 4, 5, 7 ], JCR::EvalConditions.new( mapping, nil ) ).success ).to be_truthy
  end

  it 'should demonstrate OR and AND logic 5' do
    tree = JCR.parse( '$arule =: [ ( 1 | 2 ) , ( 3 | 4 ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect( JCR.evaluate_rule( tree[0], tree[0], [ 1, 3 ], JCR::EvalConditions.new( mapping, nil ) ).success ).to be_truthy
    expect( JCR.evaluate_rule( tree[0], tree[0], [ 2, 4 ], JCR::EvalConditions.new( mapping, nil ) ).success ).to be_truthy
    expect( JCR.evaluate_rule( tree[0], tree[0], [ 1, 4 ], JCR::EvalConditions.new( mapping, nil ) ).success ).to be_truthy
    expect( JCR.evaluate_rule( tree[0], tree[0], [ 2, 3 ], JCR::EvalConditions.new( mapping, nil ) ).success ).to be_truthy
  end

  it 'should pass XOR logic' do
    tree = JCR.parse( '$arule = [ integer , ("foo" + | "bar" + ), string *]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 1, "foo", "fuzz" ], JCR::EvalConditions.new( mapping, nil, false) )
    expect( e.success ).to be_truthy
  end

  it 'should fail XOR logic' do
    tree = JCR.parse( '$arule = [ integer , ("foo" * | "bar" * ), string *]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 1, "foo", "bar" ], JCR::EvalConditions.new( mapping, nil, false) )
    expect( e.success ).to be_falsey
  end

  it 'should pass XOR logic for unordered' do
    tree = JCR.parse( '$arule = @{unordered} [ "foo" , ("bar" | "baz" ), string * ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "foo", "bar", "thing" ], JCR::EvalConditions.new( mapping, nil, false) )
    expect( e.success ).to be_truthy
  end

  it 'should fail XOR logic for unordered' do
    tree = JCR.parse( '$arule = @{unordered} [ "foo" , ("bar" | "baz" ), string * ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "foo", "bar", "baz" ], JCR::EvalConditions.new( mapping, nil, false) )
    expect( e.success ).to be_falsey
  end

end
