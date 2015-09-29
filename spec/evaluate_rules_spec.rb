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
require_relative '../lib/JCR/evaluate_rules'

describe 'evaluate_rules' do

  #
  # string value tests
  #

  it 'should pass a string constant' do
    tree = JCR.parse( 'trule : "a string constant"' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "a string constant", mapping )
    expect( e.success ).to be_truthy
  end

  it 'should fail a strng constant' do
    tree = JCR.parse( 'trule : "a string constant"' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "another string constant", mapping )
    expect( e.success ).to be_falsey
  end

  it 'should pass a string variable' do
    tree = JCR.parse( 'trule : string' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "a string constant", mapping )
    expect( e.success ).to be_truthy
  end

  it 'should fail a string variable defined as a constant' do
    tree = JCR.parse( 'trule : "a string constant"' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "another string constant", mapping )
    expect( e.success ).to be_falsey
  end

  #
  # integer value tests
  #

  it 'should pass an integer variable' do
    tree = JCR.parse( 'trule : integer' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should fail an integer variable defined as a constant' do
    tree = JCR.parse( 'trule : 3' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, mapping )
    expect( e.success ).to be_falsey
  end

  it 'should pass an integer within a range' do
    tree = JCR.parse( 'trule : 1..3' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should fail an integer below a range' do
    tree = JCR.parse( 'trule : 1..3' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 0, mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an integer above a range' do
    tree = JCR.parse( 'trule : 1..3' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 4, mapping )
    expect( e.success ).to be_falsey
  end

  it 'should pass an integer at the min of a range' do
    tree = JCR.parse( 'trule : 1..3' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 1, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an integer at the max of a range' do
    tree = JCR.parse( 'trule : 1..3' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 3, mapping )
    expect( e.success ).to be_truthy
  end

  #
  # float value tests
  #

  it 'should pass an float variable' do
    tree = JCR.parse( 'trule : float' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2.1, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should fail an float variable defined as a constant' do
    tree = JCR.parse( 'trule : 3.1' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2.1, mapping )
    expect( e.success ).to be_falsey
  end

  it 'should pass an float within a range' do
    tree = JCR.parse( 'trule : 1.1..3.1' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2.1, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should fail an float below a range' do
    tree = JCR.parse( 'trule : 1.1..3.1' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 0.1, mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail an float above a range' do
    tree = JCR.parse( 'trule : 1.1..3.1' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 4.1, mapping )
    expect( e.success ).to be_falsey
  end

  it 'should pass an float at the min of a range' do
    tree = JCR.parse( 'trule : 1.1..3.1' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 1.1, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass an float at the max of a range' do
    tree = JCR.parse( 'trule : 1.1..3.1' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 3.1, mapping )
    expect( e.success ).to be_truthy
  end

  #
  # boolean value tests
  #

  it 'should pass a false as a boolean' do
    tree = JCR.parse( 'trule : boolean' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], false, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass a true as a boolean' do
    tree = JCR.parse( 'trule : boolean' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], true, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass a true as a true' do
    tree = JCR.parse( 'trule : true' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], true, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should pass a false as a false' do
    tree = JCR.parse( 'trule : false' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], false, mapping )
    expect( e.success ).to be_truthy
  end

  it 'should fail a false as a true' do
    tree = JCR.parse( 'trule : true' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], false, mapping )
    expect( e.success ).to be_falsey
  end

  it 'should fail a true as a false' do
    tree = JCR.parse( 'trule : false' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], true, mapping )
    expect( e.success ).to be_falsey
  end

end
