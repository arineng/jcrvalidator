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

module JCR

  class Evaluation
    attr_accessor :success, :reason, :child_evaluation
    def initialize success, reason
      @success = success
      @reason = reason
    end
  end

  def self.evaluate_rule jcr, rule_atom, data, mapping
    case
      when jcr[:rule]
        return evaluate_rule( jcr[:rule], rule_atom, data, mapping)
      when jcr[:target_rule_name]
        target = mapping[ jcr[:target_rule_name][:rule_name].to_s ]
        raise "Target rule not in mapping. This should have been checked earlier." unless target
        return evaluate_rule( target, target, data, mapping )
      when jcr[:value_rule]
        return evaluate_value_rule( jcr[:value_rule], rule_atom, data, mapping)
      when jcr[:group_rule]
        return evaluate_group_rule( jcr[:group_rule], rule_atom, data, mapping)
      else
        return Evaluation.new( true, nil )
    end
  end

end
