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
require_relative '../lib/jcr/check_groups'

describe 'check_groups' do


  #
  # member rule tests
  #

  it 'should error with member with referenced member' do
    tree = JCR.parse( '$rrule = "m1" :integer  $mrule = "thing": $rrule' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error RuntimeError
  end

  it 'should be ok with member with group of two OR values' do
    tree = JCR.parse( '$mrule = "thing" :( integer | float ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should be ok with 2 member with group of two OR values' do
    tree = JCR.parse( '$mrule = "thing" :( integer | float )  $mrule2 = "thing2" :( ipv4 | ipv6 )' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should be ok with member with group of value OR group' do
    tree = JCR.parse( '$mrule = "thing" :( integer | ( ipv4 | ipv6 ) ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should be ok with member with group of value OR rulename' do
    tree = JCR.parse( '$grule =: ( ipv4 | ipv6 )  $mrule = "thing" :( integer | $grule ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should error with member with group of value OR rulename with AND' do
    tree = JCR.parse( '$grule = ( ipv4 , ipv6 )  $mrule = "thing" :( integer | $grule ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error RuntimeError
  end

  it 'should error with group with both member-rule and type-rule' do
    expect{ JCR.parse( '$grule = ( "m1" :ipv4 | ipv6 )' ) }.to raise_error Parslet::ParseFailed
  end

  it 'should error with group with member included in type-choice' do
    tree = JCR.parse( '$grule = ( "m1" : (ipv4 | ipv6) )  $mrule = "thing" :( integer | $grule ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error RuntimeError
  end

  it 'should be ok with member with group of value OR rulename' do
    tree = JCR.parse( '$grule = ( ipv4 )  $mrule = "thing" :( integer | $grule ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  #
  # value rule tests
  #
  it 'should be ok with value with group of two OR values' do
    tree = JCR.parse( '$rule =: ( integer | float ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should be ok with 2 value with group of two OR values' do
    tree = JCR.parse( '$rule =: ( integer | float )  $rule2 = ( ipv4 | ipv6 )' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should be ok with value with group of value OR group' do
    tree = JCR.parse( '$rule =: ( integer | ( ipv4 | ipv6 ) ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should be ok with value with group of value OR rulename' do
    tree = JCR.parse( '$grule = ( ipv4 | ipv6 )  $vrule = "thing" :( integer | $grule ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should error with value with group of value OR rulename with AND' do
    tree = JCR.parse( '$grule = ( ipv4 , ipv6 )  $arule = "thing" :( integer | $grule ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error RuntimeError
  end

  it 'should error with value with group with member' do
    tree = JCR.parse( '$trule =: any  $grule = ( "this" : ipv4 | "that": $trule )  $arule = "thing" :( integer | $grule ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error RuntimeError
  end

  #
  # array rule tests
  #
  it 'should be not barf on an empty array while checking for groups' do
    tree = JCR.parse( '$rule =: [ ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should be ok with array with group of two OR values' do
    tree = JCR.parse( '$rule =: [ ( integer | float ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should be ok with array with two groups of two OR values' do
    tree = JCR.parse( '$rule =: [ ( integer | float ), ( string, string ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should be ok with array with group of value OR rulename' do
    tree = JCR.parse( '$grule =: ( ipv4 | ipv6 )  $arule =: [ ( integer | $grule ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should error with array with group of value OR rulename with member' do
    tree = JCR.parse( '$trule =: any  $grule = ( "this" : ipv4 | "that": $trule )  $arule =: [ ( integer | $grule ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error RuntimeError
  end

  #
  # object rule tests
  #
  it 'should not barf on an empty object' do
    tree = JCR.parse( '$rule =: { }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should be ok with object with group of two OR values' do
    tree = JCR.parse( '$rule =: { ( "thing" :integer | "thing2" :integer ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should be ok with object with two groups of two OR members' do
    tree = JCR.parse( '$rule =: { ( "m1" :integer | "m2" :float ), ( "m3" :string, "m4" :string ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should be ok with object with group of value OR rulename' do
    tree = JCR.parse( '$grule = ( "m1" :ipv4 | "m2" :ipv6 )  $arule =: { ( "m3" :integer | $grule ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should error with object with group of value OR rulename with value' do
    tree = JCR.parse( '$trule =: any  $grule = ( ipv4 | $trule )  $arule =: { ( "m2" :integer | $grule ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error RuntimeError
  end

  it 'should error with object with group of value OR rulename with member' do
    tree = JCR.parse( '$trule =: any  $grule = ( "this" : ipv4 | "that": $trule )  $arule =: { ( "m2" :integer | "m1": $grule ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error RuntimeError
  end

  it 'should error with object with group of value OR rulename with member 2' do
    tree = JCR.parse( '$trule =: any  $grule = ( "thing": $trule )  $arule =: { ( "m2" :integer | "m1": $grule ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error RuntimeError
  end

  it 'should be ok with object with group of value OR rulename with value' do
    tree = JCR.parse( '$grule =: ( ipv4 )  $orule =: { ( "m2" :integer | "m1": $grule ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should error with object with group of value OR rulename with array' do
    tree = JCR.parse( '$trule =: any  $grule = ( [ ipv4 ], $trule )  $arule =: { ( "m2" :integer | $grule ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error RuntimeError
  end

  it 'should error with object with group of value OR rulename with array 2' do
    tree = JCR.parse( '$grule = ( [ ipv4 ] )  $arule =: { ( "m2" :integer | $grule ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error RuntimeError
  end

  it 'should error with object with group of value OR rulename with value' do
    tree = JCR.parse( '$grule = ( ipv4 )  $arule = :{ ( "m2" :integer | $grule ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error RuntimeError
  end

  it 'should error with object with group of value OR rulename with object' do
    tree = JCR.parse( '$grule = ( { "m1" :ipv4 } )  $arule = :{ ( "m2" :integer | $grule ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error RuntimeError
  end

end