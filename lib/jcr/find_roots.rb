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

require 'jcr/parser'
require 'jcr/evaluate_rules'

module JCR

  class Root
    attr_accessor :nameless, :name, :rule, :default

    def initialize rule, name = nil, nameless = true, default = false
      @rule = rule
      @name = name
      @nameless = nameless
      if name
        @nameless = false
      end
      @default = default
    end
  end

  def self.find_roots( tree )
    roots = Array.new
    if tree.is_a? Hash
      tree = [ tree ]
    end
    tree.each do |node|
      if node[:rule]
        roots.concat( find_roots_in_named( node ) )
      elsif (top_rule = get_rule_by_type( node ))
        roots << Root.new( node, nil, true, true )
        roots.concat( find_roots_in_unnamed( top_rule ) )
      end
    end
    return roots
  end

  def self.find_roots_in_named( node )
    roots = Array.new
    rn = node[:rule][:rule_name].to_str
    rule = node[:rule]
    ruledef = get_rule_by_type( rule )
    new_root = nil
    # look to see if the root_annotation is in the name before assignment ( @{root} $r = ... )
    if rule[:annotations]
      if rule[:annotations].is_a? Array
        rule[:annotations].each do |annotation|
          if annotation[:root_annotation]
            new_root = Root.new(node, rn)
            roots << new_root
            # root is found, now look into subrule for unnamed roots
            subrule = get_rule_by_type( ruledef )
            roots.concat( find_roots_in_unnamed( subrule ) ) if subrule
          end
        end
      elsif rule[:annotations][:root_annotation]
        new_root = Root.new(node, rn)
        roots << new_root
        # root is found, now look into subrule for unnamed roots
        subrule = get_rule_by_type( ruledef )
        roots.concat( find_roots_in_unnamed( subrule ) ) if subrule
      end
    end
    if ruledef && !new_root
      if ruledef.is_a? Array
        ruledef.each do |rdi|
          # if it has a @{root} annotation in the rule definition
          if rdi[:root_annotation]
            roots << Root.new(node, rn)
            # else look into the definition further and examine subrules
          elsif (subrule = get_rule_by_type(rdi))
            roots.concat(find_roots_in_unnamed(subrule))
          end
        end
      elsif ruledef.is_a? Hash
        subrule = get_rule_by_type(ruledef)
        roots.concat(find_roots_in_unnamed(subrule)) if subrule
      end
    end
    return roots
  end

  def self.find_roots_in_unnamed( node )
    roots = Array.new
    if node.is_a? Array
      node.each do |n|
        if n[:root_annotation]
          roots << Root.new( node )
        elsif (subrule = get_rule_by_type( n ) )
          roots.concat( find_roots_in_unnamed( subrule ) ) if subrule
        end
      end
    else
      subrule = get_rule_by_type( node )
      roots.concat( find_roots_in_unnamed( subrule ) ) if subrule
    end
    return roots
  end

  def self.get_rule_by_type rule
    retval = nil
    return retval unless rule.is_a? Hash
    case
      when rule[:array_rule]
        retval = rule[:array_rule]
      when rule[:object_rule]
        retval = rule[:object_rule]
      when rule[:member_rule]
        retval = rule[:member_rule]
      when rule[:primitive_rule]
        retval = rule[:primitive_rule]
      when rule[:group_rule]
        retval = rule[:group_rule]
    end
    return retval
  end

end