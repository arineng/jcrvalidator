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
require 'pp'

require 'jcr/parser'
require 'jcr/evaluate_rules'
require 'jcr/check_groups'
require 'jcr/find_roots'
require 'jcr/map_rule_names'
require 'jcr/process_directives'

module JCR

  class Context
    attr_accessor :mapping, :callbacks, :id, :tree, :roots, :catalog, :trace

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

    def initialize( ruleset = nil, trace = false )
      @trace = trace
      if ruleset
        ingested = JCR.ingest_ruleset( ruleset, false, nil )
        @mapping = ingested.mapping
        @callbacks = ingested.callbacks
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
      callbacks = {}
      callbacks.merge!( @callbacks )
      callbacks.merge!( overridden.callbacks )
      overridden.callbacks = callbacks
      overridden.roots.concat( @roots )
      return overridden
    end

    def override!( ruleset )
      overridden = JCR.ingest_ruleset( ruleset, true, nil )
      @mapping.merge!( overridden.mapping )
      @callbacks.merge!( overridden.callbacks )
      @roots.concat( overridden.roots )
    end

  end

  def self.ingest_ruleset( ruleset, override = false, ruleset_alias=nil )
    tree = JCR.parse( ruleset )
    mapping = JCR.map_rule_names( tree, override, ruleset_alias )
    JCR.check_rule_target_names( tree, mapping )
    JCR.check_groups( tree, mapping )
    roots = JCR.find_roots( tree )
    ctx = Context.new
    ctx.tree = tree
    ctx.mapping = mapping
    ctx.callbacks = {}
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
      pp "Evaluating Root:", r if ctx.trace
      raise "Root rules cannot be member rules" if r[:member_rule]
      retval = JCR.evaluate_rule( r, r, data, EvalConditions.new( ctx.mapping, ctx.callbacks, ctx.trace ) )
      break if retval.success
    end

    return retval
  end

  def self.main my_argv=nil

    my_argv = ARGV unless my_argv

    options = {}

    opt_parser = OptionParser.new do |opt|
      opt.banner = "Usage: jcr [OPTIONS] [JSON_FILES]"
      opt.separator  ""
      opt.separator  "Evaluates JSON against JSON Content Rules (JCR)."
      opt.separator  ""
      opt.separator  "If -J is not specified, JSON_FILES is used."
      opt.separator  "If JSON_FILES is not specified, standard input (STDIN) is used."
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

      opt.on("-S STRING","name of root rule. All roots will be tried if none is specified") do |root_name|
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
        options[:overrides] << File.open( ruleset ).read
      end

      opt.on("-O STRING","string containing overide rule (option can be repeated)") do |rule|
        unless options[:overrides]
          options[:overrides] = Array.new
        end
        options[:overrides] << rule
      end

      opt.on("-J STRING","string containing JSON to evaluate. Should probably be quoted") do |json|
        if options[:json]
          puts "JSON has already been specified. Use -h for help.", ""
          return 2
        end
        options[:json] = json
      end

      opt.on("-v","verbose") do |verbose|
        options[:verbose] = true
      end

      opt.on("-h","display help") do |help|
        options[:help] = true
      end
    end

    opt_parser.parse! my_argv

    if options[:help]
      puts "HELP","----",""
      puts opt_parser
      return 2
    elsif !options[:ruleset]
      puts "No ruleset passed! Use -R or -r options.", ""
      puts opt_parser
      return 2
    else

      begin

        ctx = Context.new( options[:ruleset], options[:verbose] )
        if options[:overrides]
          options[:overrides].each do |ov|
            ctx.override!( ov )
          end
        end

        if options[:verbose]
          pp "Ruleset Parse Tree", ctx.tree
          pp "Ruleset Parse Map", ctx.mapping
        end

        if options[:json]
          data = JSON.parse( options[:json] )
          ec = cli_eval( ctx, data, options[:root_name], options[:verbose] )
          return ec
        elsif $stdin.tty?
          ec = 0
          if my_argv.empty?
            ec = 2
          else
            my_argv.each do |fn|
              data = JSON.parse( File.open( fn ).read )
              tec = cli_eval( ctx, data, options[:root_name], options[:verbose] )
              ec = tec if tec != 0 #record error but don't let non-error overwrite error
            end
          end
          return ec
        else
          data = JSON.parse( ARGF.read )
          ec = cli_eval( ctx, data, options[:root_name], options[:verbose] )
          return ec
        end

      rescue Parslet::ParseFailed => failure
        puts failure.cause.ascii_tree
      end
    end

  end

  def self.cli_eval ctx, data, root_name, verbose
    ec = 2
    e = ctx.evaluate( data, root_name )
    if e.success
      if verbose
        puts "Success!"
      end
      ec = 0
    else
      if verbose
        puts "Failure: #{e.reason}"
      end
      ec = 1
    end
    return ec
  end

end