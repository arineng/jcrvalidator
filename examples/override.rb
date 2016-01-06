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

# This example demonstrates overriding rules in a ruleset with a secondary ruleset

require 'jcr'

ruleset = <<RULESET
# ruleset-id rfcXXXX
# jcr-version 0.5

[ 2 my_integers, 2 my_strings ]
my_integers :0..2
my_strings ( :"foo" | :"bar" )

RULESET

override = <<OVERRIDE
my_integers :0..1
OVERRIDE

# Create a JCR context.
ctx = JCR::Context.new( ruleset )

# Evaluate the JSON without the override
data = JSON.parse( '[ 1, 2, "foo", "bar" ]')
e = ctx.evaluate( data )
# Should be true
puts "Ruleset evaluation of JSON = " + e.success.to_s

# Create a new context with overriden rules
new_ctx = ctx.override( override )
e = new_ctx.evaluate( data )
# Should be false
puts "New Context Ruleset evaluation of JSON = " + e.success.to_s

# The first context can be modified as well
ctx.override!( override )
e = ctx.evaluate( data )
# Should be false
puts "Overriden Ruleset evaluation of JSON = " + e.success.to_s


