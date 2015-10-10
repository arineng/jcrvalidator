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
require_relative '../lib/JCR/parser'
require_relative '../lib/JCR/process_directives'

describe 'process_directives' do

  it 'should process ruleset-id directive' do
    ex = <<EX
# ruleset-id rfcXXXX
; a comment
# import http://example.com as rfcYYYY
; another comment
# jcr-version 0.5
; yet another comment
EX
    ctx = JCR::Context.new
    ctx.tree = JCR.parse( ex )
    JCR.process_directives( ctx )
    expect( ctx.id ).to eq("rfcXXXX")
  end

  it 'should process jcr-version 0.5' do
    ex = <<EX
# ruleset-id rfcXXXX
; a comment
# import http://example.com as rfcYYYY
; another comment
# jcr-version 0.5
; yet another comment
EX
    ctx = JCR::Context.new
    ctx.tree = JCR.parse( ex )
    JCR.process_directives( ctx )
  end

  it 'should fail to process jcr-version 0.5' do
    ex = <<EX
# ruleset-id rfcXXXX
# import http://example.com as rfcYYYY
# jcr-version 0.4
EX
    ctx = JCR::Context.new
    ctx.tree = JCR.parse( ex )
    expect{ JCR.process_directives( ctx ) }.to raise_error RuntimeError
  end

end