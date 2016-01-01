# Copyright (C) 2015 American Registry for Internet Numbers (ARIN)
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
require 'rspec'
require 'pp'
require 'rubygems'
require 'json'
require_relative '../lib/jcr/jcr'

describe 'jcr' do

  it 'should pass defualt rule' do
    ex = <<EX
# ruleset-id rfcXXXX
# jcr-version 0.5

[ *:integer ]

EX
    ctx = JCR.ingest_ruleset( ex )
    e = JCR.evaluate_ruleset( [ 2, 2, 2 ], ctx )
    expect( e.success ).to be_truthy
  end

  it 'should fail defualt rule' do
    ex = <<EX
# ruleset-id rfcXXXX
# jcr-version 0.5

[ *:string ]

EX
    ctx = JCR.ingest_ruleset( ex )
    e = JCR.evaluate_ruleset( [ 2, 2, 2 ], ctx )
    expect( e.success ).to be_falsey
  end

  it 'should pass defualt rule referencing another rule' do
    ex = <<EX
# ruleset-id rfcXXXX
# jcr-version 0.5

[ * my_rule ]
my_rule :0..2

EX
    ctx = JCR.ingest_ruleset( ex )
    e = JCR.evaluate_ruleset( [ 2, 2, 2 ], ctx )
    expect( e.success ).to be_truthy
  end

  it 'should pass defualt rule referencing two rules with JSON' do
    ex = <<EX
# ruleset-id rfcXXXX
# jcr-version 0.5

[ 2 my_integers, 2 my_strings ]
my_integers :0..2
my_strings ( :"foo" | :"bar" )

EX
    data = JSON.parse( '[ 1, 2, "foo", "bar" ]')
    ctx = JCR.ingest_ruleset( ex )
    e = JCR.evaluate_ruleset( data, ctx )
    expect( e.success ).to be_truthy
  end

  it 'should initialize a context and evaluate JSON' do
    ex = <<EX
# ruleset-id rfcXXXX
# jcr-version 0.5

[ 2 my_integers, 2 my_strings ]
my_integers :0..2
my_strings ( :"foo" | :"bar" )

EX
    data = JSON.parse( '[ 1, 2, "foo", "bar" ]')
    e = JCR::Context.new( ex ).evaluate( data )
    expect( e.success ).to be_truthy
  end

  it 'should initialize a context and evaluate two JSONs' do
    ex = <<EX
# ruleset-id rfcXXXX
# jcr-version 0.5

[ 2 my_integers, 2 my_strings ]
my_integers :0..2
my_strings ( :"foo" | :"bar" )

EX
    data1 = JSON.parse( '[ 1, 2, "foo", "bar" ]')
    data2 = JSON.parse( '[ 2, 1, "bar", "foo" ]')
    ctx = JCR::Context.new( ex )
    e = ctx.evaluate( data1 )
    expect( e.success ).to be_truthy
    e = ctx.evaluate( data2 )
    expect( e.success ).to be_truthy
  end

  it 'should initialize a context and evaluate two JSONs and fail a third' do
    ex = <<EX
# ruleset-id rfcXXXX
# jcr-version 0.5

[ 2 my_integers, 2 my_strings ]
my_integers :0..2
my_strings ( :"foo" | :"bar" )

EX
    data1 = JSON.parse( '[ 1, 2, "foo", "bar" ]')
    data2 = JSON.parse( '[ 2, 1, "bar", "foo" ]')
    data3 = JSON.parse( '[ 1, 20000, "foo", "bar" ]')
    ctx = JCR::Context.new( ex )
    e = ctx.evaluate( data1 )
    expect( e.success ).to be_truthy
    e = ctx.evaluate( data2 )
    expect( e.success ).to be_truthy
    e = ctx.evaluate( data3 )
    expect( e.success ).to be_falsey
  end

  it 'should pass defualt rule referencing two rules with JSON and override' do
    ex = <<EX
# ruleset-id rfcXXXX
# jcr-version 0.5

[ 2 my_integers, 2 my_strings ]
my_integers :integer
my_strings ( :"foo" | :"bar" )

EX
    ov = <<OV
my_integers :0..2
OV
    data = JSON.parse( '[ 1, 2, "foo", "bar" ]')
    ctx = JCR::Context.new( ex )
    ctx.override!( ov )
    e = ctx.evaluate( data )
    expect( e.success ).to be_truthy
  end

  it 'should fail defualt rule referencing two rules with JSON and override!' do
    ex = <<EX
# ruleset-id rfcXXXX
# jcr-version 0.5

[ 2 my_integers, 2 my_strings ]
my_integers :integer
my_strings ( :"foo" | :"bar" )

EX
    ov = <<OV
my_integers :0..1
OV
    data = JSON.parse( '[ 1, 2, "foo", "bar" ]')
    ctx = JCR::Context.new( ex )
    ctx.override!( ov )
    e = ctx.evaluate( data )
    expect( e.success ).to be_falsey
  end

  it 'should fail defualt rule referencing two rules with JSON and override!' do
    ex = <<EX
# ruleset-id rfcXXXX
# jcr-version 0.5

[ 2 my_integers, 2 my_strings ]
my_integers :integer
my_strings ( :"foo" | :"bar" )

EX
    ov = <<OV
my_integers :0..1
OV
    data = JSON.parse( '[ 1, 2, "foo", "bar" ]')
    ctx = JCR::Context.new( ex )
    new_ctx = ctx.override( ov )
    e = ctx.evaluate( data )
    expect( e.success ).to be_truthy
    e = new_ctx.evaluate( data )
    expect( e.success ).to be_falsey
  end

  it 'should evaluate JSON against multiple roots' do
    ex = <<EX
# ruleset-id rfcXXXX
# jcr-version 0.5

[ 2 my_integers, 2 my_strings ]
oroot @(root) [ 2 my_strings, 2 my_integers ]
my_integers :0..2
my_strings ( :"foo" | :"bar" )

EX
    data = JSON.parse( '[ 1, 2, "foo", "bar" ]')
    e = JCR::Context.new( ex ).evaluate( data )
    expect( e.success ).to be_truthy
    e = JCR::Context.new( ex ).evaluate( data, "oroot" )
    expect( e.success ).to be_falsey
    data = JSON.parse( '[ "foo", "bar", 1, 2 ]')
    e = JCR::Context.new( ex ).evaluate( data )
    expect( e.success ).to be_truthy
    e = JCR::Context.new( ex ).evaluate( data, "oroot" )
    expect( e.success ).to be_truthy
  end

  it 'should callback eval_true once' do
    ex = <<EX
# ruleset-id rfcXXXX
# jcr-version 0.5

[ 1*2 my_integers, 2 my_strings ]
my_integers :0..2
my_strings ( :"foo" | :"bar" )

EX
    my_eval_count = 0
    c = Proc.new do |on|
      on.rule_eval_true do |jcr,data|
        my_eval_count = my_eval_count + 1
        true
      end
    end
    data = JSON.parse( '[ 1, "foo", "bar" ]')
    ctx = JCR::Context.new( ex )
    ctx.callbacks[ "my_integers" ] = c
    e = ctx.evaluate( data )
    expect( e.success ).to be_truthy
    expect( my_eval_count ).to eq( 1 )
  end

  it 'should callback eval_true twice' do
    ex = <<EX
# ruleset-id rfcXXXX
# jcr-version 0.5

[ 2 my_integers, 2 my_strings ]
my_integers :0..2
my_strings ( :"foo" | :"bar" )

EX
    my_eval_count = 0
    c = Proc.new do |on|
      on.rule_eval_true do |jcr,data|
        my_eval_count = my_eval_count + 1
        true
      end
    end
    data = JSON.parse( '[ 1, 2, "foo", "bar" ]')
    ctx = JCR::Context.new( ex )
    ctx.callbacks[ "my_integers" ] = c
    e = ctx.evaluate( data )
    expect( e.success ).to be_truthy
    expect( my_eval_count ).to eq( 2 )
  end

  it 'should callback eval_false once' do
    ex = <<EX
# ruleset-id rfcXXXX
# jcr-version 0.5

[ 2 my_integers, 2 my_strings ]
my_integers :0..2
my_strings ( :"foo" | :"bar" )

EX
    my_eval_count = 0
    c = Proc.new do |on|
      on.rule_eval_false do |jcr,data,e|
        my_eval_count = my_eval_count + 1
        e
      end
    end
    data = JSON.parse( '[ 3, 4, "foo", "bar" ]')
    ctx = JCR::Context.new( ex )
    ctx.callbacks[ "my_integers" ] = c
    e = ctx.evaluate( data )
    expect( e.success ).to be_falsey
    expect( my_eval_count ).to eq( 1 )
  end

  it 'should callback eval_false twice by changing return value' do
    ex = <<EX
# ruleset-id rfcXXXX
# jcr-version 0.5

[ 2 my_integers, 2 my_strings ]
my_integers :0..2
my_strings ( :"foo" | :"bar" )

EX
    my_eval_count = 0
    c = Proc.new do |on|
      on.rule_eval_false do |jcr,data,e|
        my_eval_count = my_eval_count + 1
        true
      end
    end
    data = JSON.parse( '[ 3, 4, "foo", "bar" ]')
    ctx = JCR::Context.new( ex )
    ctx.callbacks[ "my_integers" ] = c
    e = ctx.evaluate( data )
    expect( e.success ).to be_truthy
    expect( my_eval_count ).to eq( 2 )
  end

end