# Copyright (C) 2017 American Registry for Internet Numbers (ARIN)
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

require 'spec_helper'
require 'rspec'
require 'pp'
require_relative '../lib/jcr/jcr'

describe 'trace fails' do

  @work_dir = nil

  before(:each) do
    @work_dir = Dir.mktmpdir
  end

  after(:each) do
    FileUtils.rm_rf( @work_dir )
  end

  it 'should use line numbers in unnamed root failures' do
    ctx = JCR::Context.new( '[ 0..2 *2, ( "foo" | "bar" ) ]', false )
    data = JSON.parse( '[1,2,"fuz","bar"]')
    e = ctx.evaluate( data )
    expect( ctx.failure_report[0] ).to eq( "- Failures for root rule at line 1")
  end

  it 'should use names in specified root failures' do
    ctx = JCR::Context.new( '$root = [ 0..2 *2, ( "foo" | "bar" ) ]', false )
    data = JSON.parse( '[1,2,"fuz","bar"]')
    e = ctx.evaluate( data, "root" )
    expect( ctx.failure_report[0] ).to eq( "- Failures for root rule named 'root'")
  end

  it 'should use names in annotated root failures' do
    ctx = JCR::Context.new( '@{root} $root = [ 0..2 *2, ( "foo" | "bar" ) ]', false )
    data = JSON.parse( '[1,2,"fuz","bar"]')
    e = ctx.evaluate( data )
    expect( ctx.failure_report[0] ).to eq( "- Failures for root rule named 'root'")
  end

  it 'should have two fail level' do
    ctx = JCR::Context.new( '[ 0..2 ]', false )
    data = JSON.parse( '["bar"]')
    e = ctx.evaluate( data )
    expect( ctx.failed_roots[0].failures.length ).to eq( 2 )
    expect( ctx.failed_roots[0].failures[0].length ).to eq( 1 )
    expect( ctx.failed_roots[0].failures[1].length ).to eq( 1 )
  end

  it 'should have two fail level w/ one fail' do
    ctx = JCR::Context.new( '[ 0..2 *2 ]', false )
    data = JSON.parse( '[1, "bar"]')
    e = ctx.evaluate( data )
    expect( ctx.failed_roots[0].failures.length ).to eq( 2 )
    expect( ctx.failed_roots[0].failures[0].length ).to eq( 1 )
    expect( ctx.failed_roots[0].failures[1].length ).to eq( 1 )
  end

  it 'should have two fail level w/ one fail also' do
    ctx = JCR::Context.new( '[ 0..2 *2 ]', false )
    data = JSON.parse( '["bar", 1]')
    e = ctx.evaluate( data )
    expect( ctx.failed_roots[0].failures.length ).to eq( 2 )
    expect( ctx.failed_roots[0].failures[0].length ).to eq( 1 )
    expect( ctx.failed_roots[0].failures[1].length ).to eq( 1 )
  end

  it 'should have two fail level w/ or' do
    ctx = JCR::Context.new( '[ "foo" | "bar" ]', false )
    data = JSON.parse( '["baz"]')
    e = ctx.evaluate( data )
    expect( ctx.failed_roots[0].failures.length ).to eq( 2 )
    expect( ctx.failed_roots[0].failures[0].length ).to eq( 1 )
    expect( ctx.failed_roots[0].failures[1].length ).to eq( 2 )
  end

  it 'should have two fail level w/ two fail' do
    ctx = JCR::Context.new( '[ ("foo" | "bar"), 0..2 ]', false )
    data = JSON.parse( '["baz", 3]')
    e = ctx.evaluate( data )
    expect( ctx.failed_roots[0].failures.length ).to eq( 3 )
    expect( ctx.failed_roots[0].failures[0].length ).to eq( 1 )
    expect( ctx.failed_roots[0].failures[1].length ).to eq( 1 )
    expect( ctx.failed_roots[0].failures[2].length ).to eq( 2 )
  end

end
