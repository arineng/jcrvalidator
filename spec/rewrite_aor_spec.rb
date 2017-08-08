# Copyright (C) 2017 American Registry for Internet Numbers (ARIN)
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
require_relative '../lib/jcr/rewrite_aor'

describe 'rewrite_aors' do

  it 'should do nothing because there are no objects' do
    ex = <<EX
[ integer* ]
EX

    e = JCR::Context.new( ex ).evaluate( [ 2, 2, 2 ] )
    expect( e.success ).to be_truthy
  end

  it 'should do find one object marked to rewrite' do
    ex = <<EX
{ "foo":string, "bar":integer }
EX

    ctx = JCR::Context.new( ex )
    e = ctx.evaluate( { "foo" => "foo", "bar" => 2 } )
    expect( e.success ).to be_truthy
    expect( ctx.tree[0][:object_aors_rewritten] ).to eq(true )
  end

  it 'should do find one object marked to rewrite' do
    ex = <<EX
$r = @{root}{ "foo":string, "bar":{ "a":integer | "b":float } }
EX

    ctx = JCR::Context.new( ex )
    e = ctx.evaluate( { "foo" => "foo", "bar" => { "a" => 2 } } )
    expect( e.success ).to be_truthy
    expect( ctx.tree[0][:rule][:object_aors_rewritten] ).to eq(true )
    expect( ctx.tree[0][:rule][:object_rule][2][:member_rule][:object_aors_rewritten] ).to eq(true )
  end

  #
  # internal method tests
  #

  it 'should find ORs at its level' do
    tree = JCR.parse( '{ "a":string | "b":integer }' )
    o = JCR.ors_at_this_level?( tree[0][:object_rule] )
    expect( o ).to be_truthy
  end

  it 'should not find ORs at its level' do
    tree = JCR.parse( '{ "a":string , "b":integer }' )
    o = JCR.ors_at_this_level?( tree[0][:object_rule] )
    expect( o ).to be_falsey
  end

  it 'should mark ORs at multiple levels' do
    ex = <<EX
{ ( "a":string, ( "d":integer | "e":string ) ) | ( "b":integer | "c":string ) }
EX
    # create a context where aor rewriting is turned off because we want to avoid a call to object level rewrite
    ctx = JCR::Context.new( ex, false, false )
    JCR.traverse_ors( ctx.tree[0][:object_rule], ctx )
    expect( ctx.tree[0][:object_rule][1][:level_ors_rewritten] ).to eq( true )
    expect( ctx.tree[0][:object_rule][1][:group_rule][1][:level_ors_rewritten] ).to eq( true )
    expect( ctx.tree[0][:object_rule][0][:group_rule][1][:group_rule][1][:level_ors_rewritten] ).to eq( true )
  end

  it 'should mark ORs at multiple levels with references' do
    # this test will likely need to be deleted or rewritten when the true rewrite occurs because a true rewrite
    # involves dereferencing everything
    ex = <<EX
{ $l1 | $l2 }
$l1 = ( "a":string, ( "d":integer | "e":string ) )
$l2 = ( "b":integer | "c":string )
EX
    # create a context where aor rewriting is turned off because we want to avoid a call to object level rewrite
    ctx = JCR::Context.new( ex, false, false )
    JCR.traverse_ors( ctx.tree[0][:object_rule], ctx )
    expect( ctx.tree[0][:object_rule][1][:level_ors_rewritten] ).to eq( true )
    expect( ctx.mapping["l2"] ).to_not be_nil
    expect( ctx.mapping["l2"][:group_rule][1][:level_ors_rewritten] ).to eq( true )
    expect( ctx.mapping["l1"] ).to_not be_nil
    expect( ctx.mapping["l1"][:group_rule][1][:group_rule][1][:level_ors_rewritten] ).to eq( true )
  end

  it 'should dereference and deep copy' do
    ex = <<EX
{ $l1 * | @{not}$l2 | @{not}$l3 | $l4 * | @{not}$l6 | $l7 }
$l1 = ( "a":string, ( $l5 | @{not}"e":string ) )
$l2 = @{not}( "b":integer | "c":string )
$l3 = @{not}"j":float
$l4 = /^k*/:any
$l5 = "d":integer
$l6 = "l":float
$l7 = "m":integer
EX
    # create a context where aor rewriting is turned off because we want to avoid a call to object level rewrite
    ctx = JCR::Context.new( ex, false, false )
    JCR.dereference_object_targets(ctx.tree[0][:object_rule], ctx )
    expect( ctx.tree[0][:object_rule][0][:group_rule] ).to_not be_nil
    expect( ctx.tree[0][:object_rule][1][:group_rule] ).to_not be_nil
    expect( ctx.tree[0][:object_rule][1][:choice_combiner] ).to_not be_nil
    expect( ctx.tree[0][:object_rule][2][:member_rule] ).to_not be_nil
    expect( ctx.tree[0][:object_rule][2][:member_rule][0][:not_annotation] ).to_not be_nil
    expect( ctx.tree[0][:object_rule][2][:choice_combiner] ).to_not be_nil
    expect( ctx.tree[0][:object_rule][3][:member_rule] ).to_not be_nil
    expect( ctx.tree[0][:object_rule][3][:member_rule][:member_regex] ).to_not be_nil
    expect( ctx.tree[0][:object_rule][3][:choice_combiner] ).to_not be_nil
    expect( ctx.tree[0][:object_rule][4][:member_rule] ).to_not be_nil
    expect( ctx.tree[0][:object_rule][4][:member_rule] ).to be_a( Array )
    expect( ctx.tree[0][:object_rule][4][:member_rule][0][:not_annotation] ).to_not be_nil
    expect( ctx.tree[0][:object_rule][4][:choice_combiner] ).to_not be_nil
    expect( ctx.tree[0][:object_rule][5][:member_rule] ).to_not be_nil
    expect( ctx.tree[0][:object_rule][5][:member_rule] ).to be_a( Hash )
    expect( ctx.tree[0][:object_rule][5][:choice_combiner] ).to_not be_nil

    # spot check to make sure we didn't harm the other rules
    expect( ctx.tree[1][:rule][:group_rule][1][:group_rule][0][:target_rule_name] ).to_not be_nil
    expect( ctx.tree[6][:rule][:rule_name].to_s ).to eq( "l6" )
    expect( ctx.tree[6][:rule][:member_rule] ).to be_a( Hash )
    expect( ctx.tree[6][:rule][:member_rule][:not_annotation] ).to be_nil
  end

end