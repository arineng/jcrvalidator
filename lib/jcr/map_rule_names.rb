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

module JCR

  def self.map_rule_names( tree )
    rule_name_maping = Hash.new
    tree.each do |node|
      if node[:rule]
        rule_name_maping[ node[:rule][:rule_name].to_str ] = node[:rule]
      end
    end
    return rule_name_maping
  end

  def self.check_rule_targets_for_names( tree, mapping )
    tree.each do |node|
      if node[:rule]
        check_node_for_rule_name( node[:rule], mapping )
      end
    end
  end

  def self.check_node_for_rule_name( node, mapping )
    if node.is_a?( Array )
      node.each do |child|
        check_node_for_rule_name( child, mapping )
      end
    else  #is a hash
      if node[:member_rule]
        check_target_rule_name( node[:member_rule], mapping )

      elsif node[:array_rule]
        node[:array_rule].each do |inner_rule|
          unless check_target_rule_name( inner_rule, mapping )
            check_node_for_rule_name( inner_rule, mapping )
          end
        end

      elsif node[:object_rule]

      elsif node[:group_rule]

      end
    end
  end

  def self.check_target_rule_name rule, mapping
    if rule.is_a?(Hash) && rule[:target_rule_name]
      trn = rule[:target_rule_name][:rule_name]
      unless mapping[ trn.to_str ]
        raise_rule_name_error trn
      end
      return true
    end
    return false
  end

  def self.raise_rule_name_error rule_name
    pos = rule_name.line_and_column
    name = rule_name.to_str
    raise "rule '" + name + "' at line " + pos[0].to_s + " column " + pos[1].to_s + " does not exist"
  end

end