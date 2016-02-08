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
require_relative '../lib/jcr/evaluate_rules'

describe 'evaluate_member_rules' do

  #
  # qstring tests
  #

  it 'should pass a member with string and any value' do
    tree = JCR.parse( 'mrule "mname" :any' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "mname", "anything" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a member with string and any value with reject' do
    tree = JCR.parse( 'mrule @{reject} "mname" :any' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "mname", "anything" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass a member with string and an integer' do
    tree = JCR.parse( 'mrule "mname" :integer' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "mname", 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a member with mismatch string and an integer' do
    tree = JCR.parse( 'mrule "mname" :integer' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "blah", 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass a member with mismatch string and an integer with reject' do
    tree = JCR.parse( 'mrule @{reject} "mname" :integer' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "blah", 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a member with string and an integer against member with string' do
    tree = JCR.parse( 'mrule "mname" :integer' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "mname", "a string" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a member with mismatch string and an integer against member with string' do
    tree = JCR.parse( 'mrule "mname" :integer' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "blah", "a string" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  #
  # regex tests
  #

  it 'should pass a member with regex and any value' do
    tree = JCR.parse( 'mrule /ab.*/ :any' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "abc", "anything" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a member with regex and any value with reject' do
    tree = JCR.parse( 'mrule @{reject} /ab.*/ :any' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "abc", "anything" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass a member with regex and an integer' do
    tree = JCR.parse( 'mrule /ab*/ :integer' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "abc", 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a member with mismatch regex and an integer' do
    tree = JCR.parse( 'mrule /ab.*/ :integer' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "blah", 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass a member with mismatch regex and an integer with reject' do
    tree = JCR.parse( 'mrule @{reject} /ab.*/ :integer' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "blah", 2 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a member with regex and an integer against member with string' do
    tree = JCR.parse( 'mrule /ab.*/ :integer' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "abc", "a string" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a member with mismatch regex and an integer against member with string' do
    tree = JCR.parse( 'mrule /ab.*/ :integer' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ "blah", "a string" ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

end
