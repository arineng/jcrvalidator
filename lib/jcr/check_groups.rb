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
      elsif tree[:member_rule]
        check_member_for_group( tree[:member_rule], mapping )
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
    node.each do |groupee|
      if groupee[:comma_o]
        raise_group_error( 'AND (comma) operation in group rule of member rule', groupee[:comma_o] )
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