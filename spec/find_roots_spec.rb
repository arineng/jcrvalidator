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
require_relative '../lib/jcr/parser'
require_relative '../lib/jcr/find_roots'

describe 'find_roots' do

  it 'should find no annotated roots with value rule' do
    tree = JCR.parse( '$vrule= integer' )
    roots = JCR.find_roots( tree )
    expect( roots.length ).to eq( 0 )
  end

  it 'should find no annotated roots with member rule' do
    tree = JCR.parse( '$vrule= "member" :integer' )
    roots = JCR.find_roots( tree )
    expect( roots.length ).to eq( 0 )
  end

  it 'should find no annotated roots with array rule' do
    tree = JCR.parse( '$vrule= [ integer <*> ]' )
    roots = JCR.find_roots( tree )
    expect( roots.length ).to eq( 0 )
  end

  it 'should find an annotated rule' do
    tree = JCR.parse( '$vrule= @{root} [ integer<*> ]' )
    roots = JCR.find_roots( tree )
    expect( roots.length ).to eq( 1 )
    expect( roots[0] ).to be_an( JCR::Root )
    expect( roots[0].name ).to eq( "vrule" )
    expect( roots[0].nameless ).to be_falsey
    expect( roots[0].rule ).to be_an( Hash )
    expect( roots[0].rule[:rule] ).to be_truthy
  end

  it 'should find an embedded annotated rule' do
    tree = JCR.parse( '$vrule= [ @{root} integer <*> ]' )
    roots = JCR.find_roots( tree )
    expect( roots.length ).to eq( 1 )
    expect( roots[0] ).to be_an( JCR::Root )
    expect( roots[0].nameless ).to be_truthy
  end

  it 'should find a sub embedded annotated rule' do
    tree = JCR.parse( '$vrule= [ [ @{root} integer <*> ] <*> ]' )
    roots = JCR.find_roots( tree )
    expect( roots.length ).to eq( 1 )
    expect( roots[0] ).to be_an( JCR::Root )
    expect( roots[0].nameless ).to be_truthy
    expect( roots[0].rule ).to be_an( Array )
  end

  it 'should find two sub embedded annotated rule' do
    tree = JCR.parse( '$vrule= [ @{root} [ @{root} integer <*> ] <*> ]' )
    roots = JCR.find_roots( tree )
    expect( roots.length ).to eq( 2 )
    expect( roots[0] ).to be_an( JCR::Root )
    expect( roots[0].nameless ).to be_truthy
    expect( roots[0].rule ).to be_an( Array )
  end

  it 'should find top level unnamed rule as root' do
    tree = JCR.parse( '[ [ integer <*> ] <*> ]' )
    roots = JCR.find_roots( tree )
    expect( roots.length ).to eq( 1 )
    expect( roots[0] ).to be_an( JCR::Root )
    expect( roots[0].nameless ).to be_truthy
    expect( roots[0].rule ).to be_an( Hash )
  end

  it 'should find top level unnamed rule as root and embedded' do
    tree = JCR.parse( '[ [ @{root}integer<*> ] <*> ]' )
    roots = JCR.find_roots( tree )
    expect( roots.length ).to eq( 2 )
    expect( roots[0] ).to be_an( JCR::Root )
    expect( roots[0].nameless ).to be_truthy
    expect( roots[0].rule ).to be_an( Hash )
  end

  it 'should find multiple roots' do
    ex7 = <<EX7
# ruleset-id http://blah.com
{
    "Image" :{
        $width, $height, "Title" :string,
        "thumbnail": @{root} { $width, $height, "Url" :uri },
        "IDs": $ids
    }
}

$width="width" : 0..1280
$height="height" : 0..1024
$ids=@{root} [ integer<*> ]

EX7
    tree = JCR.parse( ex7 )
    roots = JCR.find_roots( tree )
    expect( roots.length ).to eq( 3 )
  end

end