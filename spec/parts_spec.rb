# Copyright (C) 2016 American Registry for Internet Numbers (ARIN)
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
require_relative '../lib/jcr/parts'
require_relative '../lib/jcr/jcr'

describe 'parts' do

  @work_dir = nil

  before(:all) do
    @work_dir = Dir.mktmpdir
  end

  after(:all) do
    FileUtils.rm_r( @work_dir )
  end

  it 'should recognize a line with start_part in it' do
    p = JCR::JcrParts.new
    expect( p.get_start( "; start_part foo.jcr") ).to eq("foo.jcr")
    expect( p.get_start( ";start_part foo.jcr") ).to eq("foo.jcr")
    expect( p.get_start( " ;start_part foo.jcr") ).to eq("foo.jcr")
    expect( p.get_start( " ; start_part foo.jcr") ).to eq("foo.jcr")
    expect( p.get_start( " ; start_part  foo.jcr") ).to eq("foo.jcr")
    expect( p.get_start( " ; start_part  /tmp/foo.jcr") ).to eq("/tmp/foo.jcr")
    expect( p.get_start( " ; start_part  c:\tmp\foo.jcr") ).to eq("c:\tmp\foo.jcr")
    expect( p.get_start( " ; start_part  foo-bar.jcr") ).to eq("foo-bar.jcr")
    expect( p.get_start( " ; start_part  foo_bar.jcr") ).to eq("foo_bar.jcr")
    expect( p.get_start( " ; end_part  foo.jcr") ).to be_nil
  end

  it 'should recognize a line with all_parts in it' do
    p = JCR::JcrParts.new
    expect( p.get_all( "; all_parts foo.jcr") ).to eq("foo.jcr")
    expect( p.get_all( ";all_parts foo.jcr") ).to eq("foo.jcr")
    expect( p.get_all( " ;all_parts foo.jcr") ).to eq("foo.jcr")
    expect( p.get_all( " ; all_parts foo.jcr") ).to eq("foo.jcr")
    expect( p.get_all( " ; all_parts  foo.jcr") ).to eq("foo.jcr")
    expect( p.get_all( " ; all_parts  /tmp/foo.jcr") ).to eq("/tmp/foo.jcr")
    expect( p.get_all( " ; all_parts  c:\tmp\foo.jcr") ).to eq("c:\tmp\foo.jcr")
    expect( p.get_all( " ; all_parts  foo-bar.jcr") ).to eq("foo-bar.jcr")
    expect( p.get_all( " ; all_parts  foo_bar.jcr") ).to eq("foo_bar.jcr")
    expect( p.get_all( " ; end_part  foo.jcr") ).to be_nil
  end

  it 'should recognize a line with end_part in it' do
    p = JCR::JcrParts.new
    expect( p.get_end( "; end_part") ).to be_truthy
    expect( p.get_end( ";end_part") ).to be_truthy
    expect( p.get_end( " ;end_part") ).to be_truthy
    expect( p.get_end( " ; end_part") ).to be_truthy
    expect( p.get_end( " ; end_part") ).to be_truthy
    expect( p.get_end( " ; start_part  foo.jcr") ).to be_nil
    expect( p.get_end( "; end_part foo.jcr") ).to be_truthy
  end

  it 'should process parts' do
    rulest_fn = File.join( @work_dir, "ruleset.jcr" )
    all_parts_fn = File.join( @work_dir, "all.jcr" )
    part1_fn = File.join(@work_dir, "part1.jcr")
    part2_fn = File.join(@work_dir, "part2.jcr")
    ruleset = <<RULESET
; all_parts #{all_parts_fn}
; my jcr ruleset

$thing1 = [ integer * ]

; start_part #{part1_fn}
$thing2 = [ string * ]

; end_part

$thing3 =: "foo"
; start_part #{part2_fn}
$thing4 = [ float *]
; end_part
RULESET
    all_parts = <<ALL_PARTS
; my jcr ruleset

$thing1 = [ integer * ]

$thing2 = [ string * ]


$thing3 =: "foo"
$thing4 = [ float *]
ALL_PARTS
    part1 = <<PART1
$thing2 = [ string * ]

PART1
    part2 = <<PART2
$thing4 = [ float *]
PART2
    r = File.open( rulest_fn, "w" )
    r.write( ruleset )
    r.close
    JCR.main( [ "-r", rulest_fn, "--test-jcr", "--process-parts" ] )
    expect( File.open(all_parts_fn).read ).to eq( all_parts )
    expect( File.open(part1_fn).read ).to eq( part1 )
    expect( File.open(part2_fn).read ).to eq( part2 )
  end

end