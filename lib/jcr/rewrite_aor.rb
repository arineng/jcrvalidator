# Copyright (c) 2015-2016 American Registry for Internet Numbers
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

require 'net/http'
require 'uri'

require 'jcr/parser'
require 'jcr/evaluate_rules'
require 'jcr/map_rule_names'
require 'jcr/jcr'

module JCR

=begin
This file rewrites Augmented OR (AOR) expressions to Inclusive OR (IOR) expressions.
By rewriting the expressions, that is taking the AOR parse tree structures and converting them to IOR structures
in the parse tree, before the evaluation of JSON data against the tree it is possible to turn this feature on or
off as needed. It should also be faster, as the conversion only occurs once. Additionally, IOR structures have the
potential to be faster to execute as they can short-circuit whereas AORs cannot.

As of right now, AOR only applies to objects.
It is described in this GitHub issue: https://github.com/arineng/jcrvalidator/issues/88
See specifically
- https://github.com/arineng/jcrvalidator/issues/88#issuecomment-245556442
- https://github.com/arineng/jcrvalidator/issues/88#issuecomment-245956796
- https://github.com/arineng/jcrvalidator/issues/88#issuecomment-247169719

Here is a simple AOR to IOR example:

    { "a":string | "b":string }

converts to

    { ( "a":string, @{not}"b":any ) | ( @{not}"a":any, "b":string ) }

AOR acts as an Exclusive OR (XOR) in this simple case.

Here is a more complicated example:

    { ( "a":string, "c":int8 ) | ( "b":string, "c":int8 ) }

converts to

    { ( "a":string, "c":int8, @{not}"b":any ) | ( @{not}"a":any, "b":string, "c":int8 ) }

Here the valid JSON structures are:

    { "a":"foo", "c":1 }
    { "b":"bar", "c":1 }

but this is invalid

    { "a":"foo", "b":"bar", "c":1 }

Now let's get more complicated by throwing in multiple levels of AOR:

    { ( ( "a":string, "c":int8 ) | ( "b":string, "c":int8 ) ) | "d":int8 }

coverts to

    { ( ( "a":string, "c":int8, @{not}"b":any ) | ( @{not}"a":any, "b":string, "c":int8 ) ), @{not}"d":any |
      @{not}( ( "a":string, "c":int8, @{not}"b":any ) | ( @{not}"a":any, "b":string, "c":int8 ) ), "d":any   }

where the following is valid

    { "a":"foo", "c":1 }
    { "b":"bar", "c":1 }
    { "d":2 }

but the following is not

    { "a":"foo", "b":"bar", "c":1 }
    { "a":"foo", "c":1, "d":2 }
    { "b":"bar", "c":1, "d":2 }

Now for an even more complicated multi-level example of AORs
(don't try this at home, consult a physician before reading):

    { ( ( "a":string, "c":int8 ) | ( "b":string, "c":int8 ) ) | ( "a":string, "d":int8 ) }

coverts to

    { ( ( "a":string, "c":int8, @{not}"b":any ) | ( @{not}"a":any, "b":string, "c":int8 ) ), @{not}( "a":string, "d":any ) |
      @{not}( ( "a":string, "c":int8, @{not}"b":any ) | ( @{not}"a":any, "b":string, "c":int8 ) ), ( "a":string, "d":any )   }

where the following is valid

    { "a":"foo", "c":1 }
    { "b":"bar", "c":1 }
    { "a":"foo", "d":2 }

but the following is not

    { "a":"foo", "b":"bar", "c":1 }
    { "a":"foo", "c":1, "d":2 }
    { "b":"bar", "c":1, "d":2 }
    { "a":"foo", "b":"bar", "d":2 }


Given that the above is true, the following algorithm should be used in the rewrite:

1. traverse the tree for objects (will be going from top to bottom because the entry points for the tree are root rules)
2. when an object is found:
   1. if it is has been marked as rewritten, continue looking for more objects. Otherwise:
   2. traverse to the lowest precedent OR
   3. dereference all member rule references and group rule references recursively
   4. flatten all group rules (which should be all ANDs)
   5. rewrite the AOR as an IOR.
   6. after rewrite, go up to the next highest OR and traverse down the other side, repeating steps 2.3 and 2.4
   7. once all child ORs of a higher precedent OR are found, then it can be rewritten
   8. mark the object as having been rewritten

Steps 2.1 and 2.8 are necessary because with multiple roots and multiple rule references, its quite possible that a
rule can be found multiple times. Not only is it more efficient to process object rules only once, but reprocessing an
object rule good potentially cause very odd behavior.

This is rewriting the rules from the bottom to the top. The purpose of doing this based on ORs means that decomposing
any group rules found in the OR expression guarantees that they are only AND groups (because JCR doesn't allow
mixing ORs and ANDs in the same group).

The AOR to IOR rewrite is this:

1. Find all member rules on the left side of the OR that are not on the right side of the OR and consider them set A
  1. where "find" means match only on the member name or regex (no regex cannonicalization is to be performed)
2. Find all member rules on the right side of the OR that are not on the left side of the OR and consider them set B
  1. see 1.1
3. Find all member rules that appear on both sides of the OR and consider them set C
  1. see 1.1
4. Rewrite the left side of the OR:
  1. Copy over set A and set C
  2. For each rule in set B, copy it over and transform it in the following manner:
    1. if the rule does not have a @{not} annotation, do the following
    2. change its repetition to 1
    3. change its type to "any"
    4. give it a @{not} annotation
5. Rewrite the right side of the OR by repeating step 4, but with sets B & C copied as-is and set A transformed

Steps 4 and 5 talking about rewriting the left and right side, but the code actually needs to account for
multiple ORs at the same level (e.g. '{ "a":string | "b":integer | "c":float }').

Specifically unaccounted for in the original expression are member rules with @{not} and repetition max of 0.
They are copied over as-is.

To traverse, find, and mark rules, the following examples of the JCR parse tree are provided.

1. A free standing root rule:

    [ integer* ]

produces the following parse tree:

    [{:array_rule=>
       {:primitive_rule=>{:integer_v=>"integer"@2}, :zero_or_more=>"*"@9}}]

2. The same, but with a simple two element object rule:

    { "foo":string, "bar":integer }

produces

    [{:object_rule=>
       [{:member_rule=>
          {:member_name=>{:q_string=>"foo"@3},
           :primitive_rule=>{:string=>"string"@8}}},
        {:sequence_combiner=>","@14,
         :member_rule=>
          {:member_name=>{:q_string=>"bar"@17},
           :primitive_rule=>{:integer_v=>"integer"@22}}}]}]

3. Here is an assigned rule example:

    $r = @{root}{ "foo":string, "bar":integer }

produces

    [{:rule=>
       {:annotations=>[],
        :rule_name=>"r"@1,
        :object_rule=>
         [{:root_annotation=>"root"@7},
          {:member_rule=>
            {:member_name=>{:q_string=>"foo"@15},
             :primitive_rule=>{:string=>"string"@20}}},
          {:sequence_combiner=>","@26,
           :member_rule=>
            {:member_name=>{:q_string=>"bar"@29},
             :primitive_rule=>{:integer_v=>"integer"@34}}}]}}]

To both rewrite a rule and to mark with a symbol indicating it has been processed will require that the
reference needed is the Ruby object containing the rule type designation itself. This is unlike other areas of
code where the node[:object_rule] (or equivalent) is passed around.

=end

  def self.rewrite_aors( ctx )

    if ctx.rewrite_aors
      traverse_for_object_rules(ctx.tree, ctx )
    end

  end

  def self.traverse_for_object_rules( node, ctx )

    if node.is_a? Hash
      if node[:object_rule]
        rewrite_object_rule( node, ctx )
      end
      node.each do |child_node|
        traverse_for_object_rules( child_node, ctx )
      end
    elsif node.is_a? Array
      node.each do |child_node|
        traverse_for_object_rules( child_node, ctx )
      end
    end

  end

  def self.rewrite_object_rule( containing_rule, ctx )
    unless containing_rule[:object_aors_rewritten]
      puts("Rewriting " + get_object_rule_name(containing_rule) + " object rule:", JCR.rule_to_s( containing_rule, false ) ) if ctx.trace
      traverse_ors( containing_rule[:object_rule], ctx )
      containing_rule[:object_aors_rewritten] = true
      puts(get_object_rule_name( containing_rule) + " object rule rewritten as:", JCR.rule_to_s( containing_rule, false ) ) if ctx.trace
    end
  end

  def self.get_object_rule_name( containing_rule )
    retval = "anonymous"
    if containing_rule[:rule_name]
      retval = "$" + containing_rule[:rule_name].to_s
    end
    retval
  end

  def self.traverse_ors( rule_level, ctx )
    rule_level = [ rule_level ] unless rule_level.is_a? Array
    rule_level.each do |sub_level|
      if sub_level[:group_rule]
        traverse_ors( sub_level[:group_rule], ctx )
      elsif sub_level[:target_rule_name]
        target = ctx.mapping[ sub_level[:target_rule_name][:rule_name].to_s ]
        raise "Target rule not in mapping. This should have been checked earlier." unless target
        traverse_ors( target, ctx )
      end
    end
    if ors_at_this_level?( rule_level )
      dereference_object_targets( rule_level, ctx )
      flatten_level( rule_level )
      # TODO rewrite here
    end
  end

  def self.ors_at_this_level?( rule_level )
    retval = false
    rule_level = [ rule_level ] unless rule_level.is_a? Array
    rule_level.each do |sub_level|
      if sub_level[:sequence_combiner]
        break #can't have ORs and ANDs at same level, so if you see any ANDs just return false
      end
      if sub_level[:choice_combiner]
        sub_level[:level_ors_rewritten] = true # this is here for internal testing only and can go if it gets in the way
        retval = true
        break #just need to find one. if one is found, return true
      end
    end
    return retval
  end

  def self.dereference_object_targets( rule_level, ctx )
    # deep copying must start at the top to avoid interference with references from other places
    rule_level = [ rule_level ] unless rule_level.is_a? Array
    rule_level.map! do |sub_level|
      if sub_level[:target_rule_name]
        target = ctx.mapping[ sub_level[:target_rule_name][:rule_name].to_s ]
        raise "Target rule not in mapping. This should have been checked earlier." unless target
        target_copy = Marshal.load( Marshal.dump( target ))
        move_not_from_target( sub_level[:target_rule_name], target_copy )
        sub_level[:group_rule] = target_copy[:group_rule] if target_copy[:group_rule]
        sub_level[:member_rule] = target_copy[:member_rule] if target_copy[:member_rule]
        # we purposefully don't move over repetitions
        sub_level.delete( :target_rule_name )
        dereference_object_targets(target_copy, ctx )
      end
      sub_level
    end
    rule_level.each do |sub_level|
      if sub_level[:group_rule]
        dereference_object_targets(sub_level[:group_rule], ctx )
      end
    end
  end

  def self.move_not_from_target( source, target )
    # is there a @{not} on the source
    source_not = nil
    source[:annotations].each do |annotation|
      source_not = annotation[:not_annotation] if annotation[:not_annotation]
    end
    if source_not != nil
      # only do this if there is no @{not} on the target
      if target[:group_rule]
        g = target[:group_rule]
        if g.is_a?( Hash ) && !g[:not_annotation]
          g[:not_annotation] = source_not
        elsif g.is_a? Array
          not_annotation_found = false
          g.each do |v|
            not_annotation_found = true if v[:not_annotation]
          end
          g.insert( 0, source_not ) unless not_annotation_found
        end
      elsif target[:member_rule]
        not_annotation_found = false
        if target[:member_rule].is_a?( Hash ) && target[:member_rule][:not_annotation]
          not_annotation_found = true
        elsif target[:member_rule].is_a? Array
          target[:member_rule].each do |v|
            not_annotation_found = true if v[:not_annotation]
          end
        end
        unless not_annotation_found
          # member rules need to be rewritten as arrays if they are not
          if target[:member_rule].is_a? Hash
            a = Array.new
            target[:member_rule].each do |k,v|
              a << { k => v }
            end
            target[:member_rule] = a
          end
          target[:member_rule].insert( 0, { :not_annotation => source_not } )
        end
      end
    end
  end

  def self.flatten_level( level )
    level.each do |sub_level|
      raise "AND found during flattening AOR." if sub_level[:sequence_combiner]
      #only flatten group rules
      if sub_level[:group_rule] && !ors_at_this_level?(sub_level[:group_rule])
        new_group = { :group_rule => [] }
        sub_level[:group_rule] = [ sub_level[:group_rule] ] if sub_level[:group_rule].is_a? Hash
        sub_level[:group_rule].each do |grand_sub|
          if grand_sub[:group_rule]
            if ors_at_this_level?( grand_sub[:group_rule])
              add_to_group_rule( new_group, grand_sub )
            else
              flatten_sub_level_ands( new_group, grand_sub )
            end
          else
            add_to_group_rule( new_group, grand_sub )
          end
        end
        if new_group[:group_rule].length < 2
          sub_level[:group_rule] = new_group[:group_rule][0]
        else
          sub_level[:group_rule] = new_group[:group_rule]
        end
      end
    end
  end

  def self.flatten_sub_level_ands( group_rule, sub_level )
    sub_level[:group_rule] = [ sub_level[:group_rule] ] if sub_level[:group_rule].is_a? Hash
    sub_level[:group_rule].each do |grand_sub|
      if grand_sub[:group_rule]
        if ors_at_this_level?( grand_sub[:group_rule])
          add_to_group_rule( group_rule, grand_sub )
        else
          flatten_sub_level_ands( group_rule, grand_sub )
        end
      else
        add_to_group_rule( group_rule, grand_sub )
      end
    end
  end

  def self.add_to_group_rule( containing_rule, rules )

    # create a group rule if one is not given
    if containing_rule == nil

      containing_rule = {}

      if rules.is_a( Hash ) && rules[:group_rule]
        containing_rule[:group_rule] = rules[:group_rule]
      else
        containing_rule[:group_rule] = rules
      end

    else

      add_sequence_combiner = true

      # if the group rule is just an object, convert it to an object
      if containing_rule[:group_rule].is_a?( Hash )
        containing_rule[:group_rule] = [ containing_rule[:group_rule] ]
      elsif containing_rule[:group_rule].length == 0
        add_sequence_combiner = false
      end

      # if rules is a group rule itself
      if rules.is_a?( Hash ) && rules[:group_rule]
        # if group rule is a hash, that means it contains only one subordinate rule
        # so pull that rule out and place it directly in this group
        if rules[:group_rule].is_a?( Hash )
          unless rules[:group_rule][:sequence_combiner]
            rules[:group_rule][:sequence_combiner] = new_sequence_combiner if add_sequence_combiner
          end
          containing_rule[:group_rule] << rules[:group_rule]
        # else if the group rule has an OR in it, we want to just add that group rule as its own subordinate
        elsif ors_at_this_level?( rules[:group_rule] )
          containing_rule[:group_rule] << rules
        # else it is a group rule with ands which can be taken out and directly added here (flattened)
        else
          rules[:group_rule].each do |sub_rule|
            sub_rule[:sequence_combiner] = new_sequence_combiner if !sub_rule[:sequence_combiner] && add_sequence_combiner
            add_sequence_combiner = true
            containing_rule[:group_rule] << sub_rule
          end
        end
      elsif rules.is_a?( Hash )
        rules[:sequence_combiner] = new_sequence_combiner if !rules[:sequence_combiner] && add_sequence_combiner
        containing_rule[:group_rule] << rules
      else
        rules.each do |rule|
          rule[:sequence_combiner] = new_sequence_combiner if !rule[:sequence_combiner] && add_sequence_combiner
          add_sequence_combiner = true
          containing_rule[:group_rule] << rule
        end
      end

    end

    containing_rule

  end

  def self.new_sequence_combiner
    Parslet::Slice.new( Parslet::Position.new( "|", 0 ), "|" )
  end

  def self.new_not_annotation
    Parslet::Slice.new( Parslet::Position.new( "not", 0 ), "not" )
  end

  def self.new_any_type
    Parslet::Slice.new( Parslet::Position.new( "any", 0 ), "any" )
  end

  def self.find_common_and_uncommon_sets( level )
    # where level is either an object rule or group contained in an object rule that has already been flattened
    common_set = {} #a hash where rule_to_s(rule) is the key and the value is the rule
    uncommon_sets = [] #an array of hashes like the one above

    # iterate through each ORed sub_level ( rule | rule | rule ) and put each rule (or rules inside groups)
    # into the uncommon sets. The common ones will be moved to the common set later
    level.each do |sub_level|

      # create a hash for the sub_level
      sub_level_set = {}
      uncommon_sets << sub_level_set

      # get something we can iterate over. if its a group rule, iterate over its children
      rules = [ sub_level ]
      if sub_level[:group_rule]
        if sub_level[:group_rule].is_a?( Hash )
          rules = [ sub_level[:group_rule] ]
        else
          rules = sub_level[:group_rule]
        end
      end

      rules.each do |rule|
        h = rule_to_s( rule, false )
        sub_level_set[ h ] = rule
      end

    end

    # now find the ones that are common
    uncommon_sets.each_with_index do |set, i |
      #is in the other uncommon sets?
      set.each do |rule_s, rule|
        found_in_other = 0
        uncommon_sets.each_with_index do |other_set, other_i|
          if i != other_i && other_set[rule_s]
            found_in_other = found_in_other + 1
          end
        end
        common_set[rule_s] = rule if found_in_other == uncommon_sets.length - 1
      end
    end

    # now remove everything found in the common set from the uncommon sets
    uncommon_sets.each do |set|
      set.delete_if do |rule_s,rule|
        common_set[rule_s] != nil
      end
    end

    return common_set, uncommon_sets

  end

  # this method takes a member rule from an uncommon set, copies it, and transforms it
  def self.create_to_uncommon_aor_rule( member_rule )
    # create a copy first
    retval = Marshal.load( Marshal.dump( member_rule ) )

    # does it have a not annotation
    has_not_annotation = false
    if retval[:member_rule].is_a?( Array )
      has_not_annotation = retval[:member_rule].any? { |x| x.is_a?(Hash) && x[:not_annotation] }
    end

    unless has_not_annotation

      # give it a not annotation, which means convert it to an array
      mra = [ { :not_annotation => new_not_annotation() } ]
      retval[:member_rule].each do |k,v|
        mra << { k => v }
      end
      retval[:member_rule] = mra

      # change it's type to any
      retval[:member_rule].map! do |item|
        if item[:primitive_rule]
          { :primitive_rule => { :any => new_any_type() } }
        else
          item
        end
      end
      retval[:member_rule].keep_if do |item|
        !( item[:object_rule] || item[:array_rule] )
      end

      # remove all repetitions so the repetition is by default 1
      retval.delete( :optional )
      retval.delete( :one_or_more )
      retval.delete( :repetition_step )
      retval.delete( :zero_or_more )
      retval.delete( :repetition_interval )
      retval.delete( :repetition_min )
      retval.delete( :repetition_max )

    end
    return retval
  end

end
