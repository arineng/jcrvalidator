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
  # repetition tests
  #

  it 'should see an optional as min 0 max 1' do
    tree = JCR.parse( 'trule [ ? :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    min, max = JCR.get_repetitions( tree[0][:rule][:array_rule] )
    expect( min ).to eq(0)
    expect( max ).to eq(1)
  end

  it 'should see a one or more as min 1 max infinity' do
    tree = JCR.parse( 'trule [ + :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    min, max = JCR.get_repetitions( tree[0][:rule][:array_rule] )
    expect( min ).to eq(1)
    expect( max ).to eq(Float::INFINITY)
  end

  it 'should see a zero or more as min 0 max infinity' do
    tree = JCR.parse( 'trule [ * :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    min, max = JCR.get_repetitions( tree[0][:rule][:array_rule] )
    expect( min ).to eq(0)
    expect( max ).to eq(Float::INFINITY)
  end

  it 'should see a 1 to 4 as min 1 max 4' do
    tree = JCR.parse( 'trule [ 1*4 :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    min, max = JCR.get_repetitions( tree[0][:rule][:array_rule] )
    expect( min ).to eq(1)
    expect( max ).to eq(4)
  end

  it 'should see 22 as min 22 max 22' do
    tree = JCR.parse( 'trule [ 22 :string ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
    min, max = JCR.get_repetitions( tree[0][:rule][:array_rule] )
    expect( min ).to eq(22)
    expect( max ).to eq(22)
  end

end
