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

end
