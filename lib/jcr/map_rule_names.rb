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

  def self.check_rule_target_names( node, mapping )
    if node.is_a? Array
      node.each do |child_node|
        check_rule_target_names( child_node, mapping )
      end
    else # is a hash
      if node[:target_rule_name] && !mapping[ node[:target_rule_name][:rule_name].to_str ]
        raise_rule_name_error node[:target_rule_name][:rule_name]
      else
        if node[:rule]
          check_rule_target_names( node[:rule], mapping )
        elsif node[:array_rule]
          check_rule_target_names( node[:array_rule], mapping )
        elsif node[:object_rule]
          check_rule_target_names( node[:object_rule], mapping )
        elsif node[:member_rule]
          check_rule_target_names( node[:member_rule], mapping )
        end
      end
    end
  end

  def self.raise_rule_name_error rule_name
    pos = rule_name.line_and_column
    name = rule_name.to_str
    raise "rule '" + name + "' at line " + pos[0].to_s + " column " + pos[1].to_s + " does not exist"
  end

end