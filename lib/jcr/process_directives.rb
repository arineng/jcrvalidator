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

require 'net/http'
require 'uri'

require 'jcr/parser'
require 'jcr/evaluate_rules'
require 'jcr/map_rule_names'
require 'jcr/jcr'

module JCR

  def self.process_directives( ctx )

    tree = ctx.tree
    if tree.is_a? Hash
      tree = [ tree ]
    end

    tree.each do |node|
      if node[:directive]
        d = node[:directive]
        case
          when d[:ruleset_id_d]
            process_ruleset_id( d[:ruleset_id_d], ctx )
          when d[:import_d]
            process_import( d[:import_d], ctx )
          when d[:jcr_version_d]
            process_jcrversion( d[:jcr_version_d], ctx )
        end
      end
    end
  end

  def self.process_ruleset_id( directive, ctx )
    ctx.id = directive[:ruleset_id].to_str
  end

  def self.process_jcrversion( directive, ctx )
    major = directive[:major_version].to_str.to_i
    minor = directive[:minor_version].to_str.to_i
    if major != 0
      raise "jcr version #{major}.#{minor} is incompatible with 0.5"
    end
    if minor != 5
      raise "jcr version #{major}.#{minor} is incompatible with 0.5"
    end
  end

  def self.process_import( directive, ctx )

    ruleset_id    = directive[:ruleset_id].to_str
    ruleset_alias = directive[:ruleset_id_alias].to_str
    u = ctx.map_ruleset_alias( ruleset_alias, ruleset_id )
    uri = URI.parse( u )
    ruleset = nil
    case uri.scheme
      when "http","https"
        response = Net::HTTP.get_response uri
        ruleset = response.body
      else
        ruleset = File.open( uri.path )
    end

    import_ctx = JCR.ingest_ruleset( ruleset, false, ruleset_alias )
    ctx.mapping.merge!( import_ctx.mapping )
    ctx.roots.concat( import_ctx.roots )

  end

end