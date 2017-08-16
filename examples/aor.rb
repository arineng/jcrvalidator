# Copyright (C) 2015-2017 American Registry for Internet Numbers (ARIN)
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

#
#
# This program is to help with AOR development.
# It may also be used as guidance on using AOR with caution.
# THIS FILE IS NOT PART OF THE TEST SUITE AND MAY NOT BE UP TO DATE!!!
#
#

require 'jcr'
require 'pp'

ruleset = <<RULESET
$m1 = "a":string
$m2 = "b":integer
$m3 = "c":float
$m4 = "d":boolean

; no rewrite should occur
$o1 = { $m1, $m2 }

; should be rewritten
$o2 = { $m1 | $m2 }

$o3 = { $m1 }

$o4 = { $m1, ( $m2 | $m3 ) }

$o5 = { ( $m1 , $m2 ) | $m3 }

$o6 = { ( ( $m1, $m2 ) , $m4 ) | $m3 }

$o7 = { ( "a":string *, @{not}"b":string ) | ( ( "c":string ) * ) | ( ( "d":string ) ) }

$o8 = { ( "a":string, ( "d":integer | "e":string ) ) | ( "b":integer | "c":string ) }

RULESET

ctx = JCR::Context.new( ruleset, true, true )
#pp ctx.tree

=begin
# Evaluate the first JSON
data1 = JSON.parse( '{ "a":"foo", "b":2 }')
e1 = ctx.evaluate( data1, "o1" )
# Should be true
puts "Ruleset evaluation of JSON = " + e1.success.to_s

data2 = JSON.parse( '{ "a":"bar", "b":3 }')
e2 = ctx.evaluate( data2, "o1" )
# Should be true
puts "Ruleset evaluation of JSON = " + e2.success.to_s

#return the evaluations as an exit code
exit e1.success && e2.success
=end


