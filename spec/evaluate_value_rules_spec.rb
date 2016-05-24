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
require_relative '../lib/jcr/evaluate_value_rules'

describe 'evaluate_value_rules' do

  #
  # any values (which match more than values)
  #

  it 'should pass when any rule matches a string constant' do
    tree = JCR.parse( '$trule= any' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "a string constant", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass when any rule matches an object' do
    tree = JCR.parse( '$trule= any' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {"foo"=>"bar"}, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass when any rule matches an array' do
    tree = JCR.parse( '$trule= any' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 3 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail when any rule matches an array with {not} annotation' do
    tree = JCR.parse( '$trule= @{not} any' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [ 1, 2, 3 ], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  #
  # string value tests
  #

  it 'should pass when a string matches a string constant' do
    tree = JCR.parse( '$trule= "a string constant"' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "a string constant", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail when a string matches a string constant with {not} annotation' do
    tree = JCR.parse( '$trule= @{not} "a string constant"' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "a string constant", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail when a string does not match a string constant' do
    tree = JCR.parse( '$trule= "a string constant"' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "another string constant", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass a string variable' do
    tree = JCR.parse( '$trule= string' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "a string constant", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a string variable defined as a constant' do
    tree = JCR.parse( '$trule= "a string constant"' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "another string constant", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  #
  # integer value tests
  #

  it 'should pass an integer variable' do
    tree = JCR.parse( '$trule= integer' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an integer variable when passed a string' do
    tree = JCR.parse( '$trule= integer' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "foo", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an integer variable matching a constant' do
    tree = JCR.parse( '$trule= 3' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 3, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an integer variable not matching a constant' do
    tree = JCR.parse( '$trule=  3' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an integer variable when passed a string' do
    tree = JCR.parse( '$trule= 3' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "foo", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an integer within a range' do
    tree = JCR.parse( '$trule= 1..3' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an integer below a range' do
    tree = JCR.parse( '$trule= 1..3' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 0, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an integer above a range' do
    tree = JCR.parse( '$trule= 1..3' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 4, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an integer at the min of a range' do
    tree = JCR.parse( '$trule= 1..3' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 1, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an integer at the max of a range' do
    tree = JCR.parse( '$trule= 1..3' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 3, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an integer range when passed a string' do
    tree = JCR.parse( '$trule= 1..3' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "foo", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  #
  # float / double value tests
  #

  it 'should pass a double variable' do
    tree = JCR.parse( '$trule= double' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2.1, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a double variable when passed a string' do
    tree = JCR.parse( '$trule= double' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "foo", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass a float variable' do
    tree = JCR.parse( '$trule= float' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2.1, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a float variable when passed a string' do
    tree = JCR.parse( '$trule= float' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "foo", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass a float variable matching a constant' do
    tree = JCR.parse( '$trule= 3.1' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 3.1, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an float variable not matching a constant' do
    tree = JCR.parse( '$trule= 3.1' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2.1, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an float exact when passed a string' do
    tree = JCR.parse( '$trule= 3.1' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "foo", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an float within a range' do
    tree = JCR.parse( '$trule= 1.1..3.1' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2.1, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an float below a range' do
    tree = JCR.parse( '$trule= 1.1..3.1' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 0.1, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an float above a range' do
    tree = JCR.parse( '$trule= 1.1..3.1' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 4.1, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an float at the min of a range' do
    tree = JCR.parse( '$trule= 1.1..3.1' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 1.1, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass an float at the max of a range' do
    tree = JCR.parse( '$trule= 1.1..3.1' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 3.1, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an float range when passed a string' do
    tree = JCR.parse( '$trule= 1.1..3.1' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "foo", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  #
  # boolean value tests
  #

  it 'should pass a false as a boolean' do
    tree = JCR.parse( '$trule= boolean' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], false, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass a true as a boolean' do
    tree = JCR.parse( '$trule= boolean' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], true, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass a true as a true' do
    tree = JCR.parse( '$trule= true' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], true, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass a false as a false' do
    tree = JCR.parse( '$trule= false' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], false, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a false as a true' do
    tree = JCR.parse( '$trule= true' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], false, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a true as a false' do
    tree = JCR.parse( '$trule= false' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], true, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  #
  # null value test
  #

  it 'should pass a null' do
    tree = JCR.parse( '$trule= null' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], nil, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a null with {not} annotation' do
    tree = JCR.parse( '$trule= @{not} null' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], nil, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  #
  # regex value test
  #

  it 'should pass a string matching a regular expression' do
    tree = JCR.parse( '$trule= /[a-z]*/' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "aaa", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a string not matching a regular expression' do
    tree = JCR.parse( '$trule= /[a-z]*/' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "AAA", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a number not matching a regular expression' do
    tree = JCR.parse( '$trule= /[a-z]*/' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  #
  # IP address value tests
  #

  it 'should pass an IPv4 address that matches' do
    tree = JCR.parse( '$trule= ipv4' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "192.1.1.1", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an IPv4 address that does not match' do
    tree = JCR.parse( '$trule= ipv4' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "192.1.1.1.1.1.1", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an IPv4 address that is not a string' do
    tree = JCR.parse( '$trule= ipv4' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an IPv4 address that is suppose to be an IPv6 address' do
    tree = JCR.parse( '$trule= ipv6' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "192.1.1.1", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass an IPv6 address that matches' do
    tree = JCR.parse( '$trule= ipv6' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "2001:0000::1", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass a fully expanded IPv6 address that matches' do
    tree = JCR.parse( '$trule= ipv6' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "2001:0000:0000:0000:0000:0000:0000:0001", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an IPv6 address that does not match' do
    tree = JCR.parse( '$trule= ipv6' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "2001:0000::1....", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an IPv6 address that is not a string' do
    tree = JCR.parse( '$trule= ipv6' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], [], JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an IPv6 address that is suppose to be an IPv4 address' do
    tree = JCR.parse( '$trule= ipv4' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "2001:0000::1", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  #
  # domain value tests
  #

  it 'should pass fqdn as fqdn' do
    tree = JCR.parse( '$trule= fqdn' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "www.example.com", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a domain label that is not a string' do
    tree = JCR.parse( '$trule= fqdn' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 22, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a domain label starting with a dash' do
    tree = JCR.parse( '$trule= fqdn' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "www.-example.com", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a domain label ending with a dash' do
    tree = JCR.parse( '$trule= fqdn' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "www.example-.com", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a domain label containgin an underscore' do
    tree = JCR.parse( '$trule= fqdn' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "www.example_fail.com", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass idn as idn' do
    tree = JCR.parse( '$trule= idn' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "www.e\u0092xample.com", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an idn as fqdn' do
    tree = JCR.parse( '$trule= fqdn' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "www.e\u0092xample.com", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass a fqdn as idn' do
    tree = JCR.parse( '$trule=  idn' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "www.example.com", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an idn label starting with a dash' do
    tree = JCR.parse( '$trule=  idn' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "www.-e\u0092xample.com", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an idn that is not a string' do
    tree = JCR.parse( '$trule=  idn' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a idn label ending with a dash' do
    tree = JCR.parse( '$trule=  idn' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "www.e\u0092xample-.com", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an idn label containgin an underscore' do
    tree = JCR.parse( '$trule=  idn' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "www.e\u0092xample_fail.com", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  #
  # URI and URI template value tests
  #

  it 'should pass a URI' do
    tree = JCR.parse( '$trule=  uri' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "http://example.com", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a URI that is not a string' do
    tree = JCR.parse( '$trule=  uri' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass a URI template' do
    tree = JCR.parse( '$trule= uri..http://example.com/{?query*}' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "http://example.com/?foo=bar", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a non-matching URI template' do
    tree = JCR.parse( '$trule= uri..http://example.com/{?query*}' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "http://example.com", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a non-string against URI template' do
    tree = JCR.parse( '$trule= uri..http://example.com/{?query*}' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], {}, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  #
  # Email value tests
  #

  it 'should pass an email address match' do
    tree = JCR.parse( '$trule= email' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "example@example.com", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail an email address mismatch' do
    tree = JCR.parse( '$trule= email' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "example@example@example.com", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail an email address when it is not a string' do
    tree = JCR.parse( '$trule= email' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  #
  # Phone number value tests
  #

  it 'should pass a phone number match' do
    tree = JCR.parse( '$trule= phone' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "+34634976090", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a phone number mismatch' do
    tree = JCR.parse( '$trule= phone' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "123", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a phone number when a non-string datatype is given' do
    tree = JCR.parse( '$trule= phone' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  #
  # Hex data type
  #

  it 'should pass a hex string' do
    tree = JCR.parse( '$trule= hex' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "1234AB", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass a empty hex string' do
    tree = JCR.parse( '$trule= hex' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a number that is not a hex string' do
    tree = JCR.parse( '$trule= hex' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a string with illegal hex characters' do
    tree = JCR.parse( '$trule= hex' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "1234GH", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a hex string that does not have even length' do
    tree = JCR.parse( '$trule= hex' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "12345", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  #
  # Base32hex data type
  #

  it 'should pass a base32hex string' do
    tree = JCR.parse( '$trule= base32hex' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "ABcdEFV3", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass a empty base32hex string' do
    tree = JCR.parse( '$trule= base32hex' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a number that is not a base32hex string' do
    tree = JCR.parse( '$trule= base32hex' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a string with illegal base32hex characters' do
    tree = JCR.parse( '$trule= base32hex' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "ABcdEFCZ", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a base32hex string if length is not multiple of 8' do
    tree = JCR.parse( '$trule= base32hex' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "ABCD", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  #
  # Base32 data type
  #

  it 'should pass a base32 string' do
    tree = JCR.parse( '$trule= base32' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "ABcdEFZ3", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass a empty base32 string' do
    tree = JCR.parse( '$trule= base32' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a number that is not a base32 string' do
    tree = JCR.parse( '$trule= base32' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a string with illegal base32 characters' do
    tree = JCR.parse( '$trule= base32' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "ABcdEFZ1", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a base32 string if length is not multiple of 8' do
    tree = JCR.parse( '$trule= base32' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "ABCD", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  #
  # Base64 data type
  #

  it 'should pass a base64 string' do
    tree = JCR.parse( '$trule= base64' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "VGVz+/==", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass a empty base64 string' do
    tree = JCR.parse( '$trule= base64' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a number that is not a base64 string' do
    tree = JCR.parse( '$trule= base64' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a string with illegal base64 characters' do
    tree = JCR.parse( '$trule= base64' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "VGVzA%==", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a string with base64 characters after padding' do
    tree = JCR.parse( '$trule= base64' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "VGVzdA==aaaa", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  #
  # Base64url data type
  #

  it 'should pass a base64url string' do
    tree = JCR.parse( '$trule= base64url' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "VGVz-_==", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should pass a empty base64url string' do
    tree = JCR.parse( '$trule= base64url' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a number that is not a base64url string' do
    tree = JCR.parse( '$trule= base64url' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a string with illegal base64url characters' do
    tree = JCR.parse( '$trule= base64url' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "VGVzA%==", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a string with base64url characters after padding' do
    tree = JCR.parse( '$trule= base64url' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "VGVzdA==aaaa", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  #
  # Date and Time value tests
  #

  it 'should pass a datetime string' do
    tree = JCR.parse( '$trule= datetime' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "1985-04-12T23:20:50.52Z", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a number being passed as datetime' do
    tree = JCR.parse( '$trule= datetime' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a badly formatted datetime' do
    tree = JCR.parse( '$trule= datetime' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "1985-04-12T23.20.50.52Z", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass a date string' do
    tree = JCR.parse( '$trule= date' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "1985-04-12", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a number being passed as date' do
    tree = JCR.parse( '$trule= date' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a badly formatted date' do
    tree = JCR.parse( '$trule= date' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "1985-14-12", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should pass a time string' do
    tree = JCR.parse( '$trule= time' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "23:20:50.52", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_truthy
  end

  it 'should fail a number being passed as time' do
    tree = JCR.parse( '$trule= time' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], 2, JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a badly formatted time with Z' do
    tree = JCR.parse( '$trule= time' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "23.20.50.52Z", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

  it 'should fail a badly formatted time with bad-data' do
    tree = JCR.parse( '$trule= time' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    e = JCR.evaluate_rule( tree[0], tree[0], "24.20.50.52", JCR::EvalConditions.new( mapping, nil ) )
    expect( e.success ).to be_falsey
  end

end
