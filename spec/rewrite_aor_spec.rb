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
require 'pp'
require_relative '../lib/jcr/rewrite_aor'

describe 'rewrite_aors' do

  it 'should do nothing because there are no objects' do
    ex = <<EX
[ integer* ]
EX

    e = JCR::Context.new( ex ).evaluate( [ 2, 2, 2 ] )
    expect( e.success ).to be_truthy
  end

  it 'should find one object marked to rewrite' do
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

  it 'should check that objects do not get dereferenced if they have not ORs' do
    ex = <<EX
$m1 = "a":string
$m2 = "b":integer
$o1 = { $m1, $m2 }
$o3 = { $m1 }
EX
    ctx = JCR::Context.new( ex )
    expect( JCR.rule_to_s( ctx.tree[2]) ).to eq("$o1 = { $m1 , $m2 }")
    expect( JCR.rule_to_s( ctx.tree[3]) ).to eq("$o3 = { $m1 }")
  end

  it 'should check that objects do get dereferenced if they have ORs' do
    ex = <<EX
$m1 = "a":string
$m2 = "b":integer
$o2 = { $m1 | $m2 }
EX
    ctx = JCR::Context.new( ex )
    expect( JCR.rule_to_s( ctx.tree[2]) ).to_not include( "$m1")
    expect( JCR.rule_to_s( ctx.tree[2]) ).to_not include( "$m2")
  end

  #no double nested groups = ndng
  ndng = <<NDNG
$m1 = "a":string
$m2 = "b":integer
$m3 = "c":float
$m4 = "d":boolean
$o4 = { $m1, ( $m2 | $m3 ) }
$o5 = { ( $m1 , $m2 ) | $m3 }
$o6 = { ( ( $m1, $m2 ) , $m4 ) | $m3 }
$o7 = { ( "a":string *, @{not}"b":string ) | ( ( "c":string ) * ) | ( ( "d":string ) ) }
$o8 = { ( "a":string, ( "d":integer | "e":string ) ) | ( "b":integer | "c":string ) }
NDNG
  ndng_ctx = JCR::Context.new( ndng )
  ndng_ctx.tree.each_with_index do |rule,i|
    it 'should not have double nested groups (ndng) ' + i.to_s do
      test_val = look_for_double_nested_groups( rule )
      pp "failed rule ndng #{i}", rule if test_val
      expect( test_val ).to be_falsey
    end
  end

  def look_for_double_nested_groups( rule )
    retval = false
    if rule.is_a?( Hash )
      #is it a group rule
      if rule[:group_rule]
        #check to see if contains a group rule directly as a hash
        if rule[:group_rule].is_a?( Hash ) && rule[:group_rule][:group_rule]
          retval = true
        #check to see if contains a group rule as the only element of an array
        elsif rule[:group_rule].length == 1 && rule[:group_rule][0].is_a?( Hash ) && rule[:group_rule][0][:group_rule]
          retval = true
        else
          retval = look_for_double_nested_groups( rule[:group_rule] )
        end
      else
        rule.each do |k,sub_rule|
          retval = look_for_double_nested_groups( sub_rule )
          break if retval
        end
      end
    elsif rule.is_a?( Array )
      rule.each do |sub_rule|
        retval = look_for_double_nested_groups( sub_rule )
        break if retval
      end
    end
    return retval
  end

  # groups_with_one_subrule_with_combiner = gwoswr
  gwoswr = <<GWOSWR
$m1 = "a":string
$m2 = "b":integer
$m3 = "c":float
$m4 = "d":boolean
$o4 = { $m1, ( $m2 | $m3 ) }
$o5 = { ( $m1 , $m2 ) | $m3 }
$o6 = { ( ( $m1, $m2 ) , $m4 ) | $m3 }
$o7 = { ( "a":string *, @{not}"b":string ) | ( ( "c":string ) * ) | ( ( "d":string ) ) }
$o8 = { ( "a":string, ( "d":integer | "e":string ) ) | ( "b":integer | "c":string ) }
GWOSWR
  gwoswr_ctx = JCR::Context.new( gwoswr )
  gwoswr_ctx.tree.each_with_index do |rule, i |
    it 'should find no groups with one subrule that has a combiner (gwoswr) ' + i.to_s do
      test_val = look_for_groups_with_one_subrule_with_a_combiner( rule )
      pp "failed rule gwoswr #{i}", rule if test_val
      expect( test_val ).to be_falsey
    end
  end

  def look_for_groups_with_one_subrule_with_a_combiner( rule )
    retval = false
    if rule.is_a?( Hash )
      #is it a group rule
      if rule[:group_rule]
        #check to see if contains a group rule directly as a hash
        if rule[:group_rule].is_a?( Hash )
          if rule[:group_rule][:sequence_combiner] || rule[:group_rule][:choice_combiner]
            retval = true
          end
        #check to see if contains a group rule as the only element of an array
        elsif rule[:group_rule].length == 1 && rule[:group_rule][0].is_a?( Hash )
          if rule[:group_rule][0][:sequence_combiner] || rule[:group_rule][0][:choice_combiner]
            retval = true
          end
        else
          retval = look_for_double_nested_groups( rule[:group_rule] )
        end
      else
        rule.each do |k,sub_rule|
          retval = look_for_double_nested_groups( sub_rule )
          break if retval
        end
      end
    elsif rule.is_a?( Array )
      rule.each do |sub_rule|
        retval = look_for_double_nested_groups( sub_rule )
        break if retval
      end
    end
    return retval
  end

  # groups_with_both_ands_and_ors = gwbaao
  gwbaao = <<GWBAAO
$m1 = "a":string
$m2 = "b":integer
$m3 = "c":float
$m4 = "d":boolean
$o4 = { $m1, ( $m2 | $m3 ) }
$o5 = { ( $m1 , $m2 ) | $m3 }
$o6 = { ( ( $m1, $m2 ) , $m4 ) | $m3 }
$o7 = { ( "a":string *, @{not}"b":string ) | ( ( "c":string ) * ) | ( ( "d":string ) ) }
$o8 = { ( "a":string, ( "d":integer | "e":string ) ) | ( "b":integer | "c":string ) }
GWBAAO
  gwbaao_ctx = JCR::Context.new( gwbaao )
  gwbaao_ctx.tree.each_with_index do |rule, i|
    it 'should not have any groups with both ANDS and ORs for rule (gwbaao) ' + i.to_s do
      test_val = look_for_groups_with_ands_and_ors( rule )
      pp "failed rule gwbaao #{i}" ,rule if test_val
      expect( test_val ).to be_falsey
    end
  end

  def look_for_groups_with_ands_and_ors( rule )
    retval = false
    if rule.is_a?( Hash )
      #is it a group rule as an array (cuz Hash group rules can only have one item)
      if rule[:group_rule] && rule[:group_rule].is_a?( Array )
        found_ands = false
        found_ors = false
        rule[:group_rule].each do |sub_rule|
          found_ands = true if sub_rule[:sequence_combiner]
          found_ors = true if sub_rule[:choice_combiner]
        end
        if found_ands && found_ors
          retval = true
        end
      else
        rule.each do |k,sub_rule|
          retval = look_for_groups_with_ands_and_ors( sub_rule )
          break if retval
        end
      end
    elsif rule.is_a?( Array )
      rule.each do |sub_rule|
        retval = look_for_groups_with_ands_and_ors( sub_rule )
        break if retval
      end
    end
    return retval
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

  it 'should find and assemble the common and uncommon sets for three simple combinations' do
    tree = JCR.parse( '{ "a":string | "b":integer | "c":boolean }')
    # test the sets
    common_set, uncommon_sets = JCR.find_common_and_uncommon_sets( tree[0][:object_rule] )
    expect( common_set.empty? ).to be
    expect( uncommon_sets.length ).to eql( 3 )
    expect( uncommon_sets[0]['"a" : string'] ).to_not be_nil
    expect( uncommon_sets[1]['"b" : integer'] ).to_not be_nil
    expect( uncommon_sets[1]['"b" : integer'][:choice_combiner] ).to be_nil
    expect( uncommon_sets[2]['"c" : boolean'] ).to_not be_nil
    expect( uncommon_sets[2]['"c" : boolean'][:choice_combiner] ).to be_nil
    # test the assembly
    JCR.assemble_sets( tree[0][:object_rule], common_set, uncommon_sets )
    expected = <<EXPECTED
{ ( "a" : string , @{not} "b" : any , @{not} "c" : any ) | ( @{not} "a" : any , "b" : integer , @{not} "c" : any ) | ( @{not} "a" : any , @{not} "b" : any , "c" : boolean ) }
EXPECTED
    expect( JCR.rule_to_s( tree[0], false ) ).to eql( expected.strip )
  end

  it 'should find and assemble the common and uncommon sets for three simple combinations of an annotated object rule' do
    tree = JCR.parse( '@{root}{ "a":string | "b":integer | "c":boolean }')
    # test the sets
    common_set, uncommon_sets = JCR.find_common_and_uncommon_sets( tree[0][:object_rule] )
    expect( common_set.empty? ).to be
    expect( uncommon_sets.length ).to eql( 3 )
    expect( uncommon_sets[0]['"a" : string'] ).to_not be_nil
    expect( uncommon_sets[1]['"b" : integer'] ).to_not be_nil
    expect( uncommon_sets[2]['"c" : boolean'] ).to_not be_nil
    # test the assembly
    JCR.assemble_sets( tree[0][:object_rule], common_set, uncommon_sets )
    expected = <<EXPECTED
@{root} { ( "a" : string , @{not} "b" : any , @{not} "c" : any ) | ( @{not} "a" : any , "b" : integer , @{not} "c" : any ) | ( @{not} "a" : any , @{not} "b" : any , "c" : boolean ) }
EXPECTED
    expect( JCR.rule_to_s( tree[0], false ) ).to eql( expected.strip )
  end

  it 'should find and assemble the common and uncommon sets for three complex non-intersecting combinations' do
    tree = JCR.parse( '{ ("a":string,"d":string) | ("b":integer,"e":float) | ("c":boolean,"f":double) }')
    # test the sets
    common_set, uncommon_sets = JCR.find_common_and_uncommon_sets( tree[0][:object_rule] )
    expect( common_set.empty? ).to be
    expect( uncommon_sets.length ).to eql( 3 )
    expect( uncommon_sets[0]['"a" : string'] ).to_not be_nil
    expect( uncommon_sets[0]['"d" : string'] ).to_not be_nil
    expect( uncommon_sets[1]['"b" : integer'] ).to_not be_nil
    expect( uncommon_sets[1]['"e" : float'] ).to_not be_nil
    expect( uncommon_sets[2]['"c" : boolean'] ).to_not be_nil
    expect( uncommon_sets[2]['"f" : double'] ).to_not be_nil
    # test the assembly
    JCR.assemble_sets( tree[0][:object_rule], common_set, uncommon_sets )
    expected =
      '{ ' +
         '( "a" : string , "d" : string , @{not} "b" : any , @{not} "e" : any , @{not} "c" : any , @{not} "f" : any ) | ' +
         '( @{not} "a" : any , @{not} "d" : any , "b" : integer , "e" : float , @{not} "c" : any , @{not} "f" : any ) | ' +
         '( @{not} "a" : any , @{not} "d" : any , @{not} "b" : any , @{not} "e" : any , "c" : boolean , "f" : double ) '  +
      '}'
    expect( JCR.rule_to_s( tree[0], false ) ).to eql( expected.strip )
  end

  it 'should find the common and uncommon sets for three complex non-intersecting combinations of an annotated object' do
    tree = JCR.parse( '@{root}{ ("a":string,"d":string) | ("b":integer,"e":float) | ("c":boolean,"f":double) }')
    common_set, uncommon_sets = JCR.find_common_and_uncommon_sets( tree[0][:object_rule] )
    expect( common_set.empty? ).to be
    expect( uncommon_sets.length ).to eql( 3 )
    expect( uncommon_sets[0]['"a" : string'] ).to_not be_nil
    expect( uncommon_sets[0]['"d" : string'] ).to_not be_nil
    expect( uncommon_sets[1]['"b" : integer'] ).to_not be_nil
    expect( uncommon_sets[1]['"e" : float'] ).to_not be_nil
    expect( uncommon_sets[2]['"c" : boolean'] ).to_not be_nil
    expect( uncommon_sets[2]['"f" : double'] ).to_not be_nil
  end

  it 'should find and assemble the common and uncommon sets for three complex intersecting combinations' do
    tree = JCR.parse( '{ ("a":string,"d":string) | ("a":string,"e":float) | ("a":string,"f":double) }')
    # test the sets
    common_set, uncommon_sets = JCR.find_common_and_uncommon_sets( tree[0][:object_rule] )
    expect( common_set.length ).to eql( 1 )
    expect( common_set['"a" : string'] ).to_not be_nil
    expect( uncommon_sets.length ).to eql( 3 )
    expect( uncommon_sets[0]['"a" : string'] ).to be_nil
    expect( uncommon_sets[0]['"d" : string'] ).to_not be_nil
    expect( uncommon_sets[1]['"a" : string'] ).to be_nil
    expect( uncommon_sets[1]['"e" : float'] ).to_not be_nil
    expect( uncommon_sets[2]['"a" : string'] ).to be_nil
    expect( uncommon_sets[2]['"f" : double'] ).to_not be_nil
    # test the assembly
    JCR.assemble_sets( tree[0][:object_rule], common_set, uncommon_sets )
    expected =
      '{ ' +
        '( "a" : string , "d" : string , @{not} "e" : any , @{not} "f" : any ) | ' +
        '( "a" : string , @{not} "d" : any , "e" : float , @{not} "f" : any ) | ' +
        '( "a" : string , @{not} "d" : any , @{not} "e" : any , "f" : double ) '  +
      '}'
    expect( JCR.rule_to_s( tree[0], false ) ).to eql( expected.strip )
  end

  it 'should transform a member rule with no annotations' do
    tree = JCR.parse( '{ "a":string }' )
    xformed = JCR.create_uncommon_aor_rule(tree[0][:object_rule] )
    expect( JCR.rule_to_s(xformed) ).to eql('@{not} "a" : any')
  end

  it 'should transform an optional member rule with no annotations' do
    tree = JCR.parse( '{ "a":string ? }' )
    xformed = JCR.create_uncommon_aor_rule(tree[0][:object_rule] )
    expect( JCR.rules_to_s( [ xformed ]) ).to eql('@{not} "a" : any')
  end

  it 'should transform a zero or more member rule with no annotations' do
    tree = JCR.parse( '{ "a":string * }' )
    xformed = JCR.create_uncommon_aor_rule(tree[0][:object_rule] )
    expect( JCR.rules_to_s( [ xformed ]) ).to eql('@{not} "a" : any')
  end

  it 'should transform a one or more member rule with no annotations' do
    tree = JCR.parse( '{ "a":string + }' )
    xformed = JCR.create_uncommon_aor_rule(tree[0][:object_rule] )
    expect( JCR.rules_to_s( [ xformed ]) ).to eql('@{not} "a" : any')
  end

  it 'should transform a specific number  member rule with no annotations' do
    tree = JCR.parse( '{ "a":string *3 }' )
    xformed = JCR.create_uncommon_aor_rule(tree[0][:object_rule] )
    expect( JCR.rules_to_s( [ xformed ]) ).to eql('@{not} "a" : any')
  end

  it 'should transform a specific range member rule with no annotations' do
    tree = JCR.parse( '{ "a":string *3..4 }' )
    xformed = JCR.create_uncommon_aor_rule(tree[0][:object_rule] )
    expect( JCR.rules_to_s( [ xformed ]) ).to eql('@{not} "a" : any')
  end

  it 'should transform a specific range with skip member rule with no annotations' do
    tree = JCR.parse( '{ "a":string *3..4%2 }' )
    xformed = JCR.create_uncommon_aor_rule(tree[0][:object_rule] )
    expect( JCR.rules_to_s( [ xformed ]) ).to eql('@{not} "a" : any')
  end

  it 'should not transform a member rule with a not annotation' do
    tree = JCR.parse( '{ @{not}"a":string ? }' )
    xformed = JCR.create_uncommon_aor_rule(tree[0][:object_rule] )
    expect( JCR.rules_to_s( [ xformed ]) ).to eql('@{not} "a" : string ?')
  end

end