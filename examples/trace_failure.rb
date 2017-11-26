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

# This example demonstrates using the tracing feature of the JcRValidator
# for troubleshooting validation issues.

require 'jcr'

ruleset = <<RULESET
# ruleset-id rfcXXXX
# jcr-version 0.7

[ $my_integers *2, $my_strings *2, $my_object ]
$my_integers =: 0..2
$my_strings = ( "foo" | "bar" )
$my_object = { "name" : "bob" }
RULESET

json = <<JSON
[ 1, 2, "foo", "bar", { "name" : "alice" } ]
JSON

# Create a JCR context.
# We explicitly put tracing to false.
ctx = JCR::Context.new( ruleset, false )

# Evaluate the JSON
data1 = JSON.parse( json )
e1 = ctx.evaluate( data1 )
# Should be false
puts "Ruleset evaluation of JSON = " + e1.success.to_s

# however, we still have access to failure data
# including a report.
ctx.failure_report.each do |line|
  puts line
end

# return the evaluations as an exit code
exit !e1.success


