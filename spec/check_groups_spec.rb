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
    tree = JCR.parse( 'mrule "thing" ( :integer | :float ) mrule2 "thing2" ( :ip4 | :ip6 )' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should error with 1 member with group of OR values and member with group of AND values' do
    tree = JCR.parse( 'mrule "thing" ( :integer | :float ) mrule2 "thing2" ( :ip4 , :ip6 )' )
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
    tree = JCR.parse( 'grule ( :ip4 | :ip6 ) mrule "thing" ( :integer | grule ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
  end

  it 'should error with member with group of value OR rulename with AND' do
    tree = JCR.parse( 'grule ( :ip4 , :ip6 ) mrule "thing" ( :integer | grule ) ' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    expect{ JCR.check_groups( tree, mapping ) }.to raise_error
  end

end