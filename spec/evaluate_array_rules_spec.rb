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
require_relative '../lib/JCR/evaluate_array_rules'

describe 'evaluate_array_rules' do

  it 'should fail something that is not an array' do
    tree = JCR.parse( 'trule [ ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, mapping )
    expect( e.success ).to be_falsey
  end

  it 'should pass an empty array against an empty array rule' do
    tree = JCR.parse( 'trule [ ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [], mapping )
    expect( e.success ).to be_truthy
  end

  it 'should fail a non-empty array against an empty array rule' do
    tree = JCR.parse( 'trule [ ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing" ], mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an empty array against an array rule with a string' do
    tree = JCR.parse( 'trule [ :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ ], mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an empty array against an array rule with a string and a string' do
    tree = JCR.parse( 'trule [ :string, :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ ], mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an empty array against an array rule with a string or a string' do
    tree = JCR.parse( 'trule [ :string| :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ ], mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with one string against an array rule with a string and a string' do
    tree = JCR.parse( 'trule [ :string, :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing" ], mapping )
    expect( e.success ).to be_falsey
  end

  it 'should pass an array with one string against an array rule with a string or a string' do
    tree = JCR.parse( 'trule [ :string | :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing" ], mapping )
    expect( e.success ).to be_truthy
  end

  it 'should fail an array with one string against an array rule with a string and an integer' do
    tree = JCR.parse( 'trule [ :string, :integer ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing" ], mapping )
    expect( e.success ).to be_falsey
  end

  it 'should pass an array with string and integer against an array rule with a string and an integer' do
    tree = JCR.parse( 'trule [ :string, :integer ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", 2 ], mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with one string against an array rule with a string or a integer' do
    tree = JCR.parse( 'trule [ :string | :integer ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing" ], mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with string and integer against an array rule with a string and an integer or string' do
    tree = JCR.parse( 'trule [ :string, :integer | :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", 2 ], mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with string and string against an array rule with a string and an integer or string' do
    tree = JCR.parse( 'trule [ :string, :integer | :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2" ], mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings against an array rule with string twice' do
    tree = JCR.parse( 'trule [ 2*2 :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2" ], mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings against an array rule with string once or twice' do
    tree = JCR.parse( 'trule [ 1*2 :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2" ], mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings against an array rule with string once or twice or thrice' do
    tree = JCR.parse( 'trule [ 1*3 :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2" ], mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with one string against an array rule with string once or twice' do
    tree = JCR.parse( 'trule [ 1*2 :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing" ], mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with one string against an array rule with string default or twice' do
    tree = JCR.parse( 'trule [ *2 :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing" ], mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an empty array against an array rule with string default or twice' do
    tree = JCR.parse( 'trule [ *2 :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ ], mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with one string against an array rule with string once or default' do
    tree = JCR.parse( 'trule [ 1* :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing" ], mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings against an array rule with string once or default' do
    tree = JCR.parse( 'trule [ 1* :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2" ], mapping )
    expect( e.success ).to be_truthy
  end

  it 'should fail an array with a string and integer against an array rule with string once or twice' do
    tree = JCR.parse( 'trule [ 1*2 :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", 2 ], mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with three strings against an array rule with string once or twice' do
    tree = JCR.parse( 'trule [ 1*2 :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing1", "thing2" ], mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with three strings against an array rule with string zero or twice' do
    tree = JCR.parse( 'trule [ 0*2 :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing1", "thing2" ], mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with five strings against an array rule with string zero or twice' do
    tree = JCR.parse( 'trule [ 0*2 :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing1", "thing2", "thing3", "thing4" ], mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with three strings against an array rule with string twice' do
    tree = JCR.parse( 'trule [ 2*2 :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing1", "thing2" ], mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with two strings and integer against an array rule with string twice' do
    tree = JCR.parse( 'trule [ 2*2 :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing1", 2 ], mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with a string and integer against an array rule with string default or twice' do
    tree = JCR.parse( 'trule [ *2 :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", 2 ], mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with a string and integer and string against an array rule with string and integer' do
    tree = JCR.parse( 'trule [ :string, :integer ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", 2, "thing2" ], mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an array with a string against an array rule with string twice' do
    tree = JCR.parse( 'trule [ 2*2 :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing" ], mapping )
    expect( e.success ).to be_falsey
  end

  it 'should pass an array with a string and integer against an array rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( 'trule [ 1*2 :string, 1*2 :integer ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", 2 ], mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings and integer against an array rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( 'trule [ 1*2 :string, 1*2 :integer ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", 2 ], mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with one string and two integer against an array rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( 'trule [ 1*2 :string, 1*2 :integer ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", 1, 2 ], mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two string and two integer against an array rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( 'trule [ 1*2 :string, 1*2 :integer ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", 1, 2 ], mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an array with two strings and two integers against an array rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( 'trule [ 1*2 :string, 1*2 :integer ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", "thing2", 1, 2 ], mapping )
    expect( e.success ).to be_truthy
  end

  it 'should fail an array with one string and three integer against an array rule with string 1*2 and integer 1*2' do
    tree = JCR.parse( 'trule [ 1*2 :string, 1*2 :integer ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "thing", 1, 2, 3 ], mapping )
    expect( e.success ).to be_falsey
  end

end
