# Copyright (c) 2015 American Registry for Internet Numbers
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

require 'ipaddr'
require 'time'
require 'addressable/uri'
require 'addressable/template'
require 'email_address_validator'
require 'big-phoney'

require 'jcr/parser'
require 'jcr/map_rule_names'
require 'jcr/check_groups'
require 'jcr/evaluate_rules'

module JCR

  def self.evaluate_member_rule jcr, rule_atom, data, mapping

    # unlike the other evaluate functions, here data is not just the json data.
    # it is an array, the first element being the member name or regex and the
    # second being the json data to be furthered on to other evaluation functions

    member_match = false

    if jcr[:member_name]
      match_spec = jcr[:member_name][:q_string].to_s
      if match_spec == data[ 0 ]
        member_match = true
      end
    else # must be regex
      match_spec = Regexp.new( jcr[:member_regex][:regex].to_s )
      if match_spec =~ data[ 0 ]
        member_match = true
      end
    end

    if member_match
      e = evaluate_rule( jcr, rule_atom, data[ 1 ], mapping )
      return e
    end

    return Evaluation.new( false, "#{match_spec} does not match #{data[0]} for #{jcr} from #{rule_atom}" )

  end

end
