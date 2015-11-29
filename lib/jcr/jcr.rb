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

require 'optparse'
require 'rubygems'
require 'json'

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

    def evaluate( data, root_name = nil )
      JCR.evaluate_ruleset( data, self, root_name )
    end

    def initialize( ruleset = nil )
      if ruleset
        ingested = JCR.ingest_ruleset( ruleset, false, nil )
        @mapping = ingested.mapping
        @id = ingested.id
        @tree = ingested.tree
        @roots = ingested.roots
      end
    end

    def override( ruleset )
      overridden = JCR.ingest_ruleset( ruleset, true, nil )
      mapping = {}
      mapping.merge!( @mapping )
      mapping.merge!( overridden.mapping )
      overridden.mapping=mapping
      overridden.roots.concat( @roots )
      return overridden
    end

    def override!( ruleset )
      overridden = JCR.ingest_ruleset( ruleset, true, nil )
      @mapping.merge!( overridden.mapping )
      @roots.concat( overridden.roots )
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
    root_rules = []
    if root_name
      root_rule = ctx.mapping[root_name]
      raise "No rule by the name of #{root_name} for a root rule has been found" unless root_rule
      root_rules << root_rule
    else
      ctx.roots.each do |r|
        root_rules << r.rule
      end
    end

    raise "No root rule defined. Specify a root rule name" if root_rules.empty?

    retval = nil
    root_rules.each do |r|
      retval = JCR.evaluate_rule( r, r, data, ctx.mapping )
      break if retval.success
    end

    return retval
  end

  def self.main

    options = {}

    opt_parser = OptionParser.new do |opt|
      opt.banner = "Usage: jcr [OPTIONS] [JSON_FILE]"
      opt.separator  ""
      opt.separator  "Evaluates JSON against JSON Content Rules (JCR)."
      opt.separator  ""
      opt.separator  "If JSON_FILE is not specified, standard input (STDIN) is used."
      opt.separator  ""
      opt.separator  "Use -v to see results, otherwise check the exit code."
      opt.separator  ""
      opt.separator  "Options"

      opt.on("-r FILE","file containing ruleset") do |ruleset|
        if options[:ruleset]
          puts "A ruleset has already been specified. Use -h for help.", ""
          return 2
        end
        options[:ruleset] = File.open( ruleset ).read
      end

      opt.on("-R STRING","string containing ruleset. Should probably be quoted") do |ruleset|
        if options[:ruleset]
          puts "A ruleset has already been specified. Use -h for help.", ""
          return 2
        end
        options[:ruleset] = ruleset
      end

      opt.on("-s STRING","name of root rule. All roots will be tried if none is specified") do |root_name|
        if options[:root_name]
          puts "A root has already been specified. Use -h for help.", ""
          return 2
        end
        options[:root_name] = root_name
      end

      opt.on("-o FILE","file containing overide ruleset (option can be repeated)") do |ruleset|
        unless options[:overrides]
          options[:overrides] = Array.new
        end
        options[:overrides] << File.open( ruleset )
      end

      opt.on("-v","verbose") do |verbose|
        options[:verbose] = true
      end

      opt.on("-h","display help") do |help|
        options[:help] = true
      end
    end

    opt_parser.parse!

    if options[:help]
      puts "HELP","----",""
      puts opt_parser
      return 2
    elsif !options[:ruleset]
      puts "No ruleset passed! Use -R or -r options.", ""
      puts opt_parser
      return 2
    else

      ctx = Context.new( options[:ruleset] )
      if options[:overrides]
        options[:overrides].each do |ov|
          ctx.override( ov )
        end
      end
      data = JSON.parse( ARGF.read )
      e = ctx.evaluate( data, options[:root_name] )
      if e.success
        if options[:verbose]
          puts "Success!"
        end
        return 0
      else
        if options[:verbose]
          puts "Failure: #{e.reason}"
        end
        return 1
      end

    end

  end

end