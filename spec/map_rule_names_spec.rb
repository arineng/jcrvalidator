# Copyright (C) 2015-2016 American Registry for Internet Numbers (ARIN)
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
require_relative '../lib/jcr/map_rule_names'

describe 'check_names' do

  it 'should map rule names' do
    ex7 = <<EX7
# ruleset-id http://blah.com
$width = "width" : 0..1280
$height = "height" : 0..1024

$root = :{
    "Image" :{
        $width, $height, "Title" :string,
        "thumbnail" :{ $width, $height, "Url" :uri },
        "IDs" : [ integer* ]
    }
}
EX7
    tree = JCR.parse( ex7 )
    mapping = JCR.map_rule_names( tree )
    expect( mapping["width"][:rule_name].to_str ).to eq( "width" )
    expect( mapping["height"][:rule_name].to_str ).to eq( "height" )
    expect( mapping["root"][:rule_name].to_str ).to eq( "root" )
  end

  it 'should check rule names' do
    tree = JCR.parse( '$vrule = :integer  $mrule = "thing" :  $vrule' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
  end

  it 'should raise error with missing member rule' do
    tree = JCR.parse( '$vrule =: integer  $mrule = "thing" : $missingrule' )
    mapping = JCR.map_rule_names( tree )
    expect{ JCR.check_rule_target_names( tree, mapping ) }.to raise_error RuntimeError
  end

  it 'should find rule names in array' do
    tree = JCR.parse( '$vrule1 =: integer  $vrule2 =: float $arule =: [ $vrule1, $vrule2 ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
  end

  it 'should find rule names in array of array' do
    tree = JCR.parse( '$vrule1 =: integer  $arule =: [ $vrule1, [ $vrule1 ] ]' )
    mapping = JCR.map_rule_names( tree )
    JCR.check_rule_target_names( tree, mapping )
  end

  it 'should not find rule names in array of array' do
    tree = JCR.parse( '$vrule1 =: integer  $arule =: [ $vrule1, [ $vrule2 ] ]' )
    mapping = JCR.map_rule_names( tree )
    expect{ JCR.check_rule_target_names( tree, mapping ) }.to raise_error RuntimeError
  end

  it 'should not find rule names in array of array in array' do
    tree = JCR.parse( '$vrule1 =: integer  $arule =: [ $vrule1, [ $vrule1, [ $vrule2 ] ] ]' )
    mapping = JCR.map_rule_names( tree )
    expect{ JCR.check_rule_target_names( tree, mapping ) }.to raise_error RuntimeError
  end

  it 'should not allow rules with the same name' do
    tree = JCR.parse( '$vrule =: integer  $vrule =: string' )
    expect{ JCR.map_rule_names( tree ) }.to raise_error RuntimeError
  end

  it 'should  allow rules with the same name' do
    tree = JCR.parse( '$vrule =: integer  $vrule =: string' )
    mapping = JCR.map_rule_names( tree, true )
    JCR.check_rule_target_names( tree, mapping )
  end

  it 'should map just a default rule' do
    tree = JCR.parse( '[ integer* ]' )
    mapping = JCR.map_rule_names( tree, true )
    JCR.check_rule_target_names( tree, mapping )
  end

  it 'should map rule names with prefix' do
    ex7 = <<EX7
# ruleset-id http://blah.com
$width = "width" : 0..1280
$height = "height" : 0..1024

$root =: {
    "Image": {
        $width, $height, "Title" :string,
        "thumbnail" :{ $width, $height, "Url" :uri },
        "IDs" :[ integer* ]
    }
}
EX7
    tree = JCR.parse( ex7 )
    mapping = JCR.map_rule_names( tree, false, "rfc4267" )
    expect( mapping["rfc4267.width"][:rule_name].to_str ).to eq( "width" )
    expect( mapping["rfc4267.height"][:rule_name].to_str ).to eq( "height" )
    expect( mapping["rfc4267.root"][:rule_name].to_str ).to eq( "root" )
  end

  it 'should map rule names with prefix that ends in .' do
    ex7 = <<EX7
# ruleset-id http://blah.com
$width = "width" : 0..1280
$height = "height" : 0..1024

$root =: {
    "Image" :{
        $width, $height, "Title" :string,
        "thumbnail": { $width, $height, "Url" :uri },
        "IDs": [ integer* ]
    }
}
EX7
    tree = JCR.parse( ex7 )
    mapping = JCR.map_rule_names( tree, false, "rfc4267." )
    expect( mapping["rfc4267.width"][:rule_name].to_str ).to eq( "width" )
    expect( mapping["rfc4267.height"][:rule_name].to_str ).to eq( "height" )
    expect( mapping["rfc4267.root"][:rule_name].to_str ).to eq( "root" )
  end

end