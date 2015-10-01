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

  def self.evaluate_group_rule jcr, rule_atom, data, mapping

    retval = nil

    if jcr.is_a? Hash
      jcr = [ jcr ]
    end
    jcr.each do |rule|
      e = evaluate_rule( rule, rule_atom, data, mapping )
      unless retval
        retval = e
      end
      if rule[:choice_combiner]
        if e.success
          retval = Evaluation.new( true, nil )
          retval.child_evaluation = e
          return retval # short circuit
        else
          retval = Evaluation.new( false, "Group evaluated to false" )
          retval.child_evaluation = e
        end
      elsif rule[:sequence_combiner]
        if !(e.success)
          retval = Evaluation.new( false, "Group evaluated to false" )
          retval.child_evaluation = e
          return retval # short circuit
        else
          retval = Evaluation.new( true, nil )
          retval.child_evaluation = e
        end
      end
    end

    return retval
  end

end
