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
require 'jcr/evaluate_rules'
require 'jcr/check_groups'
require 'jcr/find_roots'
require 'jcr/map_rule_names'
require 'jcr/process_directives'

module JCR

  class Context
    attr_accessor :mapping, :id, :tree, :roots, :catalog

    def add_ruleset_alias( ruleset_alias, alias_uri )
      unless @catalog
        @catalog = Hash.new
      end
      @catalog[ ruleset_alias ] = alias_uri
    end

    def remove_ruleset_alias( ruleset_alias )
      if @catalog
        @catalog.delete( ruleset_alias )
      end
    end

    def map_ruleset_alias( ruleset_alias, alias_uri )
      if @catalog
        a = @catalog[ ruleset_alias ]
        if a
          return a
        end
      end
      #else
      return alias_uri
    end
  end

  def self.ingest_ruleset( ruleset, override = false, ruleset_alias=nil )
    tree = JCR.parse( ruleset )
    mapping = JCR.map_rule_names( tree, override, ruleset_alias )
    JCR.check_rule_target_names( tree, mapping )
    roots = JCR.find_roots( tree )
    ctx = Context.new
    ctx.tree = tree
    ctx.mapping = mapping
    ctx.roots = roots
    JCR.process_directives( ctx )
    return ctx
  end

  def self.evaluate_ruleset( data, ctx, root_name = nil )
    root_rule = nil
    if root_name
      root_rule = ctx.mapping[root_name]
      raise "No rule by the name of #{root_name} for a root rule has been found" unless root_rule
    elsif ctx.roots.length > 1
      raise "With #{ctx.roots.length} roots defined, a root rule name must be specified"
    else
      root_rule = ctx.roots[ 0 ].rule
    end

    raise "No root rule defined. Specify a root rule name" unless root_rule

    return JCR.evaluate_rule( root_rule, root_rule, data, ctx.mapping )
  end

end