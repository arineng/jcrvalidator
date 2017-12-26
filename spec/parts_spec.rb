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
require_relative '../lib/jcr/parts'
require_relative '../lib/jcr/jcr'

describe 'parts' do

  @work_dir = nil

  before(:each) do
    @work_dir = Dir.mktmpdir
  end

  after(:each) do
    FileUtils.rm_rf( @work_dir )
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

    #setup ruleset
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
    xml_refs = <<XMLREFS
<!ENTITY all PUBLIC '' '#{all_parts_fn}'>
<!ENTITY part1 PUBLIC '' '#{part1_fn}'>
<!ENTITY part2 PUBLIC '' '#{part2_fn}'>
XMLREFS
    r = File.open( rulest_fn, "w" )
    r.write( ruleset )
    r.close

    #setup override ruleset
    override_fn = File.join( @work_dir, "override.jcr" )
    ov_all_fn = File.join( @work_dir, "ov_all.jcr" )
    ov_p1_fn = File.join( @work_dir, "ov_p1.jcr" )
    ov_p2_fn = File.join( @work_dir, "ov_p2.jcr" )
    override = <<OVERRIDE
; all_parts #{ov_all_fn}
; my jcr ruleset

$thing1 = [ string * ]

; start_part #{ov_p1_fn}
$thing2 = [ integer * ]

; end_part

$thing3 =: "bar"
; start_part #{ov_p2_fn}
$thing4 = [ boolean *]
; end_part
OVERRIDE
    ov_all = <<OV_ALL
; my jcr ruleset

$thing1 = [ string * ]

$thing2 = [ integer * ]


$thing3 =: "bar"
$thing4 = [ boolean *]
OV_ALL
    ov_p1 = <<OV_P1
$thing2 = [ integer * ]

OV_P1
    ov_p2 = <<OV_P2
$thing4 = [ boolean *]
OV_P2
    ov_xml_refs = <<OV_XMLREFS
<!ENTITY ov_all PUBLIC '' '#{ov_all_fn}'>
<!ENTITY ov_p1 PUBLIC '' '#{ov_p1_fn}'>
<!ENTITY ov_p2 PUBLIC '' '#{ov_p2_fn}'>
OV_XMLREFS
    o = File.open( override_fn, "w" )
    o.write( override )
    o.close

    # EXECUTE!!!
    JCR.main( [ "-r", rulest_fn, "-o", override_fn, "--test-jcr", "--process-parts" ] )

    # Test the ruleset
    expect( File.open(all_parts_fn).read ).to eq( all_parts )
    expect( File.open(part1_fn).read ).to eq( part1 )
    expect( File.open(part2_fn).read ).to eq( part2 )
    xml_fn = File.join( @work_dir, "all_xml_entity_refs" )
    expect( File.open(xml_fn).read ).to eq( xml_refs )

    # Test the overrides
    expect( File.open(ov_all_fn).read ).to eq( ov_all )
    expect( File.open(ov_p1_fn).read ).to eq( ov_p1 )
    expect( File.open(ov_p2_fn).read ).to eq( ov_p2 )
    ov_xml_fn = File.join( @work_dir, "ov_all_xml_entity_refs" )
    expect( File.open(ov_xml_fn).read ).to eq( ov_xml_refs )

  end

  it 'should process parts with a directory' do

    #setup ruleset
    rulest_fn = File.join( @work_dir, "ruleset.jcr" )
    all_parts_fn = File.join( @work_dir, "all.jcr" )
    part1_fn = File.join(@work_dir, "part1.jcr")
    part2_fn = File.join(@work_dir, "part2.jcr")
    ruleset = <<RULESET
; all_parts all.jcr
; my jcr ruleset

$thing1 = [ integer * ]

; start_part part1.jcr
$thing2 = [ string * ]

; end_part

$thing3 =: "foo"
; start_part part2.jcr
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
    xml_refs = <<XMLREFS
<!ENTITY all PUBLIC '' '#{all_parts_fn}'>
<!ENTITY part1 PUBLIC '' '#{part1_fn}'>
<!ENTITY part2 PUBLIC '' '#{part2_fn}'>
XMLREFS
    r = File.open( rulest_fn, "w" )
    r.write( ruleset )
    r.close

    #setup override ruleset
    override_fn = File.join( @work_dir, "override.jcr" )
    ov_all_fn = File.join( @work_dir, "ov_all.jcr" )
    ov_p1_fn = File.join( @work_dir, "ov_p1.jcr" )
    ov_p2_fn = File.join( @work_dir, "ov_p2.jcr" )
    override = <<OVERRIDE
; all_parts ov_all.jcr
; my jcr ruleset

$thing1 = [ string * ]

; start_part ov_p1.jcr
$thing2 = [ integer * ]

; end_part

$thing3 =: "bar"
; start_part ov_p2.jcr
$thing4 = [ boolean *]
; end_part
OVERRIDE
    ov_all = <<OV_ALL
; my jcr ruleset

$thing1 = [ string * ]

$thing2 = [ integer * ]


$thing3 =: "bar"
$thing4 = [ boolean *]
OV_ALL
    ov_p1 = <<OV_P1
$thing2 = [ integer * ]

OV_P1
    ov_p2 = <<OV_P2
$thing4 = [ boolean *]
OV_P2
    ov_xml_refs = <<OV_XMLREFS
<!ENTITY ov_all PUBLIC '' '#{ov_all_fn}'>
<!ENTITY ov_p1 PUBLIC '' '#{ov_p1_fn}'>
<!ENTITY ov_p2 PUBLIC '' '#{ov_p2_fn}'>
OV_XMLREFS
    o = File.open( override_fn, "w" )
    o.write( override )
    o.close

    # EXECUTE!!!
    JCR.main( [ "-r", rulest_fn, "-o", override_fn, "--test-jcr", "--process-parts", @work_dir ] )

    # Test the ruleset
    expect( File.open(all_parts_fn).read ).to eq( all_parts )
    expect( File.open(part1_fn).read ).to eq( part1 )
    expect( File.open(part2_fn).read ).to eq( part2 )
    xml_fn = File.join( @work_dir, "all_xml_entity_refs" )
    expect( File.open(xml_fn).read ).to eq( xml_refs )

    # Test the overrides
    expect( File.open(ov_all_fn).read ).to eq( ov_all )
    expect( File.open(ov_p1_fn).read ).to eq( ov_p1 )
    expect( File.open(ov_p2_fn).read ).to eq( ov_p2 )
    ov_xml_fn = File.join( @work_dir, "ov_all_xml_entity_refs" )
    expect( File.open(ov_xml_fn).read ).to eq( ov_xml_refs )

  end

end