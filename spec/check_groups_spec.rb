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
require_relative '../lib/JCR/check_groups'

describe 'check_groups' do


  #
  # member rule tests
  #

  it 'should be ok with member with group of two OR values' do
    tree = JCR.parse( 'mrule "thing" ( :integer | :float ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should error with member with group of two ANDED values' do
    tree = JCR.parse( 'mrule "thing" ( :integer , :float ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with member with group of ORed and ANDED values' do
    tree = JCR.parse( 'mrule "thing" ( :integer | :string , :float ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should be ok with 2 member with group of two OR values' do
    tree = JCR.parse( 'mrule "thing" ( :integer | :float ) ;; mrule2 "thing2" ( :ip4 | :ip6 )' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should error with 1 member with group of OR values and member with group of AND values' do
    tree = JCR.parse( 'mrule "thing" ( :integer | :float ) ;; mrule2 "thing2" ( :ip4 , :ip6 )' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should be ok with member with group of value OR group' do
    tree = JCR.parse( 'mrule "thing" ( :integer | ( :ip4 | :ip6 ) ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should error with member with group of value OR group' do
    tree = JCR.parse( 'mrule "thing" ( :integer | ( :ip4 , :ip6 ) ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should be ok with member with group of value OR rulename' do
    tree = JCR.parse( 'grule ( :ip4 | :ip6 ) ;; mrule "thing" ( :integer | grule ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should error with member with group of value OR rulename with AND' do
    tree = JCR.parse( 'grule ( :ip4 , :ip6 ) ;; mrule "thing" ( :integer | grule ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with member with group of value OR rulename with AND' do
    tree = JCR.parse( 'grule ( "m1" :ip4 | :ip6 ) ;; mrule "thing" ( :integer | grule ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should be ok with member with group of value OR rulename' do
    tree = JCR.parse( 'grule ( :ip4 ) ;; mrule "thing" ( :integer | grule ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  #
  # value rule tests
  #
  it 'should be ok with value with group of two OR values' do
    tree = JCR.parse( 'rule : ( :integer | :float ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should error with value with group of two ANDED values' do
    tree = JCR.parse( 'rule : ( :integer , :float ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with value with group of ORed and ANDED values' do
    tree = JCR.parse( 'rule : ( :integer | :string , :float ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should be ok with 2 value with group of two OR values' do
    tree = JCR.parse( 'rule : ( :integer | :float ) ;; rule2 : ( :ip4 | :ip6 )' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should error with 1 value with group of OR values and value with group of AND values' do
    tree = JCR.parse( 'rule : ( :integer | :float ) ;; rule2 : ( :ip4 , :ip6 )' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should be ok with value with group of value OR group' do
    tree = JCR.parse( 'rule : ( :integer | ( :ip4 | :ip6 ) ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should error with value with group of value OR group' do
    tree = JCR.parse( 'rule : ( :integer | ( :ip4 , :ip6 ) ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should be ok with value with group of value OR rulename' do
    tree = JCR.parse( 'grule ( :ip4 | :ip6 ) ;; vrule "thing" ( :integer | grule ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should error with value with group of value OR rulename with AND' do
    tree = JCR.parse( 'grule ( :ip4 , :ip6 ) ;; arule "thing" ( :integer | grule ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with value with group with member' do
    tree = JCR.parse( 'grule ( :ip4 | "thing" target ) ;; arule "thing" ( :integer | grule ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with value with group of value OR group with member' do
    tree = JCR.parse( 'rule : ( :integer | ( :ip4 | "thing" target ) ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with value with group of value OR group with array' do
    tree = JCR.parse( 'rule : ( :integer | ( :ip4 | [ :integer ] ) ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with value with group of value OR group with object' do
    tree = JCR.parse( 'rule : ( :integer | ( :ip4 | { "thing" : integer } ) ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  #
  # array rule tests
  #
  it 'should be ok with array with group of two OR values' do
    tree = JCR.parse( 'rule [ ( :integer | :float ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should be ok with array with two groups of two OR values' do
    tree = JCR.parse( 'rule [ ( :integer | :float ), ( :string, :string ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should error with array with group of one member' do
    tree = JCR.parse( 'rule [ ( "thing" target ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with array with group of one value and one member' do
    tree = JCR.parse( 'rule [ ( :integer, "thing" target ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with array with value and group of one value and one member' do
    tree = JCR.parse( 'rule [ :string, ( :integer, "thing" target ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with array with group of OR values and array with group of values and member' do
    tree = JCR.parse( 'rule [ ( :integer | :float ) ] ;; rule2 [ ( :ip4 , "thing" target ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with array with group of value OR with group with member' do
    tree = JCR.parse( 'rule [ ( :integer | ( :ip4 | "thign" target ) ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should be ok with array with group of value OR rulename' do
    tree = JCR.parse( 'grule ( :ip4 | :ip6 ) ;; arule [ ( :integer | grule ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should error with array with group of value OR rulename with member' do
    tree = JCR.parse( 'grule ( :ip4 , "thing" target ) ;; arule [ ( :integer | grule ) ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  #
  # object rule tests
  #
  it 'should be ok with object with group of two OR values' do
    tree = JCR.parse( 'rule { ( "thing" :integer | "thing2" :integer ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should be ok with object with two groups of two OR members' do
    tree = JCR.parse( 'rule { ( "m1" :integer | "m2" :float ), ( "m3" :string, "m4" :string ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should error with object with group with member and value' do
    tree = JCR.parse( 'rule { ( "thing" :integer | :integer ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with object with two groups of members and values 1' do
    tree = JCR.parse( 'rule { ( "m1" :integer | "m2" :float ), ( "m3" :string, :string ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with object with two groups of members and values 2' do
    tree = JCR.parse( 'rule { ( "m1" :integer | :float ), ( "m3" :string, "m4" :string ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should be ok with object with group of value OR rulename' do
    tree = JCR.parse( 'grule ( "m1" :ip4 | "m2" :ip6 ) ;; arule { ( "m3" :integer | grule ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should error with object with group of value OR rulename with value' do
    tree = JCR.parse( 'grule ( :ip4 , "thing" target ) ;; arule { ( "m2" :integer | grule ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with object with group of value OR rulename with member' do
    tree = JCR.parse( 'grule ( :ip4 , "thing" target ) ;; arule { ( "m2" :integer | "m1" grule ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with object with group of value OR rulename with member 2' do
    tree = JCR.parse( 'grule ( "thing" target ) ;; arule { ( "m2" :integer | "m1" grule ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should be ok with object with group of value OR rulename with value' do
    tree = JCR.parse( 'grule ( :ip4 ) ;; orule { ( "m2" :integer | "m1" grule ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should error with object with group of value OR rulename with array' do
    tree = JCR.parse( 'grule ( [ :ip4 ], "thing" target ) ;; arule { ( "m2" :integer | grule ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with object with group of value OR rulename with array 2' do
    tree = JCR.parse( 'grule ( [ :ip4 ] ) ;; arule { ( "m2" :integer | grule ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with object with group of value OR rulename with value' do
    tree = JCR.parse( 'grule ( :ip4 ) ;; arule { ( "m2" :integer | grule ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with object with group of value OR rulename with object' do
    tree = JCR.parse( 'grule ( { "m1" :ip4 } ) ;; arule { ( "m2" :integer | grule ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with object with group of value OR object' do
    tree = JCR.parse( 'arule { ( "m2" :integer | { "m1" :integer } ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with object with group of value OR array' do
    tree = JCR.parse( 'arule { ( "m2" :integer | [ :integer ] ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

  it 'should error with object with group of value OR value' do
    tree = JCR.parse( 'arule { ( "m2" :integer | :integer ) }' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

end