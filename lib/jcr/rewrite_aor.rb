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
   4. rewrite the AOR as an IOR.
   5. after rewrite, go up to the next highest OR and traverse down the other side, repeating steps 2.3 and 2.4
   6. once all child ORs of a higher precedent OR are found, then it can be rewritten
   7. mark the object as having been rewritten

Steps 2.1 and 2.7 are necessary because with multiple roots and multiple rule references, its quite possible that a
rule can be found multiple times. Not only is it more efficient to process object rules only once, but reprocessing an
object rule good potentially cause very odd behavior.

This is rewriting the rules from the bottom to the top.

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

    traverse_for_object_rules(ctx.tree, ctx )

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

  def self.rewrite_object_rule( object_rule, ctx )
    unless object_rule[:aors_rewritten]
      object_rule[:aors_rewritten] = TrueClass
    end
  end

end
