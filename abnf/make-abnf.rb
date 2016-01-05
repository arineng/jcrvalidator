# Copyright (C) 2014,2015 American Registry for Internet Numbers (ARIN)
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

# Configuration
$parslet_src_file = "../lib/jcr/parser.rb"
$abnf_out_file = "jcr-abnf-rb.txt"
$margin = 0
$indent = 19
$keyword_indent = 30

# Primary data stores
$mappings = Hash.new
$lines = []
$keywords = Hash.new

def main
    read_parslet_def
    write_abnf
end

def read_parslet_def
    IO.foreach( $parslet_src_file ) { |line|
        conditionally_grab_mapping( line )
        conditionally_grab_abnf( line )
        conditionally_grab_keywords( line )
    }
end

def conditionally_grab_mapping( line )
    # Example haystack:  #/ spcCmnt -> sp-cmt
    if m = %r|^\s*#/\s*([\w?]+)\s*->\s*(.*)|.match( line )
        key, value = m.captures
        $mappings[key] = value
    end
end

def conditionally_grab_abnf( line )
    # Example haystack:  #! spcCmnt = spaces / comment
    if m = /^\s*#!\s*(.*)/.match( line )
        $lines << m[1]
    end
end

def conditionally_grab_keywords( line )
    # Example haystack:  #> jcr-version-kw = "jcr-version"
    if m = /^\s*#>\s*([\w_\-]+kw)(\s*=\s*)"([^"]+)"/.match( line )
        name, equals, keyword = m.captures
        ascii_codes = keyword.chars.map{ |c| sprintf( "%02X", c.ord ) }.join( '.' )
        comment_padding = ' ' * [($keyword_indent - 3*keyword.length), 0].max
        line = name + equals + '%x' + ascii_codes + comment_padding + ' ; "' + keyword + '"'
        $keywords[name] = line
    end
end

def write_abnf
    puts "Shall be writing to #{$abnf_out_file}!"
end

main
