# Copyright (c) 2015 American Registry for Internet Numbers
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
require 'jcr/map_rule_names'

module JCR

  def self.check_groups( tree, mapping )
    if tree.is_a? Array
      tree.each do |node|
        check_groups( node, mapping )
      end
    else # is a hash
      if tree[:rule]
        check_groups( tree[:rule], mapping )
      elsif tree[:primitive_rule]
        check_value_for_group( tree[:primitive_rule], mapping )
      elsif tree[:member_rule]
        check_member_for_group( tree[:member_rule], mapping )
      elsif tree[:array_rule]
        check_array_for_group( tree[:array_rule], mapping )
      elsif tree[:object_rule]
        check_object_for_group( tree[:object_rule], mapping )
      end
    end
  end

  def self.check_value_for_group node, mapping
    if node.is_a?( Hash ) && node[:group_rule]
      disallowed_group_in_value?( node[:group_rule], mapping )
    end
  end

  def self.disallowed_group_in_value? node, mapping
    if node.is_a? Hash
      node = [ node ]
    end
    node.each do |groupee|
      if groupee[:sequence_combiner]
        raise_group_error( 'AND (comma) operation in group rule of value rule', groupee[:sequence_combiner] )
      end
      if groupee[:group_rule]
        disallowed_group_in_value?( groupee[:group_rule], mapping )
      elsif groupee[:target_rule_name]
        trule = get_name_mapping( groupee[:target_rule_name][:rule_name], mapping )
        disallowed_group_in_value?( trule[:rule], mapping )
      elsif groupee[:member_rule]
        raise_group_error( "groups in value rules cannot have member rules", groupee[:member_rule] )
      elsif groupee[:object_rule]
        raise_group_error( "groups in value rules cannot have object rules", groupee[:member_rule] )
      elsif groupee[:array_rule]
        raise_group_error( "groups in value rules cannot have array rules", groupee[:member_rule] )
      elsif groupee[:primitive_rule]
        disallowed_group_in_value?( groupee[:primitive_rule], mapping )
      end
    end
  end

  def self.check_member_for_group node, mapping
    if node[:target_rule_name]
      trule = get_name_mapping( node[:target_rule_name][:rule_name], mapping )
      disallowed_group_in_member?( trule, mapping )
    elsif node[:group_rule]
      disallowed_group_in_member?( node[:group_rule], mapping )
    else
      check_groups( node, mapping )
    end
  end

  def self.disallowed_group_in_member? node, mapping
    if node.is_a? Hash
      node = [ node ]
    end
    node.each do |groupee|
      if groupee[:sequence_combiner]
        raise_group_error( 'AND (comma) operation in group rule of member rule', groupee[:sequence_combiner] )
      end
      if groupee[:group_rule]
        disallowed_group_in_member?( groupee[:group_rule], mapping )
      elsif groupee[:target_rule_name]
        trule = get_name_mapping( groupee[:target_rule_name][:rule_name], mapping )
        if trule[:group_rule]
          disallowed_group_in_member?( trule[:group_rule], mapping )
        end
      elsif groupee[:member_rule]
        raise_group_error( "groups in member rules cannot have member rules", groupee[:member_rule] )
      else
        check_groups( groupee, mapping )
      end
    end
  end

  def self.check_array_for_group node, mapping
    if node.is_a?( Array )
      node.each do |child_node|
        check_array_for_group( child_node, mapping )
      end
    elsif node.is_a? Hash
      if node[:target_rule_name]
        trule = get_name_mapping(node[:target_rule_name][:rule_name], mapping)
        disallowed_group_in_array?(trule, mapping)
      elsif node[:group_rule]
        disallowed_group_in_array?(node[:group_rule], mapping)
      else
        check_groups(node, mapping)
      end
    end
  end

  def self.disallowed_group_in_array? node, mapping
    if node.is_a? Hash
      node = [ node ]
    end
    node.each do |groupee|
      if groupee[:group_rule]
        disallowed_group_in_array?( groupee[:group_rule], mapping )
      elsif groupee[:target_rule_name]
        trule = get_name_mapping( groupee[:target_rule_name][:rule_name], mapping )
        if trule[:group_rule]
          disallowed_group_in_array?( trule[:group_rule], mapping )
        end
      elsif groupee[:member_rule]
        raise_group_error( "groups in array rules cannot have member rules", groupee[:member_rule] )
      else
        check_groups( groupee, mapping )
      end
    end
  end

  def self.check_object_for_group node, mapping
    if node.is_a?( Array )
      node.each do |child_node|
        check_object_for_group( child_node, mapping )
      end
    elsif node.is_a? Hash
      if node[:target_rule_name]
        trule = get_name_mapping(node[:target_rule_name][:rule_name], mapping)
        disallowed_group_in_object?(trule, mapping)
      elsif node[:group_rule]
        disallowed_group_in_object?(node[:group_rule], mapping)
      else
        check_groups(node, mapping)
      end
    end
  end

  def self.disallowed_group_in_object? node, mapping
    if node.is_a? Hash
      node = [ node ]
    end
    node.each do |groupee|
      if groupee[:group_rule]
        disallowed_group_in_object?( groupee[:group_rule], mapping )
      elsif groupee[:target_rule_name]
        trule = get_name_mapping( groupee[:target_rule_name][:rule_name], mapping )
        if trule[:group_rule]
          disallowed_group_in_object?( trule[:group_rule], mapping )
        end
      elsif groupee[:array_rule]
        raise_group_error( "groups in object rules cannot have array rules", groupee[:member_rule] )
      elsif groupee[:object_rule]
        raise_group_error( "groups in object rules cannot have other object rules", groupee[:member_rule] )
      elsif groupee[:primitive_rule]
        raise_group_error( "groups in object rules cannot have value rules", groupee[:member_rule] )
      else
        check_groups( groupee, mapping )
      end
    end
  end

  def self.raise_group_error str, node
    if node.is_a?( Parslet::Slice )
      pos = node.line_and_column
      name = node.to_str
      raise "group rule error at line " + pos[0].to_s + " column " + pos[1].to_s + " name '" + name + "' :" + str
    else
      raise "group rule error with '" + node.to_s + "' :" + str
    end
  end

end