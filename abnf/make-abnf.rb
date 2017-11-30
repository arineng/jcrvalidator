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
$abnf_out_file = "jcr-abnf.txt"
$margin = 0
$indent = 19
$keyword_indent = 30

# Primary data stores
$mappings = {}
$lines = []
$keywords = {}

def main
    read_parslet_def
    write_abnf
end

def read_parslet_def
    File.foreach( $parslet_src_file ) { |line|
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
        ascii_codes = keyword.chars.map{ |c| "%02X" % c.ord }.join( '.' )
        comment_padding = ' ' * [($keyword_indent - 3*keyword.length), 0].max
        line = name + equals + '%x' + ascii_codes + comment_padding + ' ; "' + keyword + '"'
        $keywords[name] = line
    end
end

def write_abnf
    File.open( $abnf_out_file, 'w' ) { |fout|
        print_captured_abnf( fout )
        print_keywords( fout )
        print_referenced_rfc5234_rules( fout )
    }
end

def print_captured_abnf( fout )
    for line in $lines
        line = do_name_mappings( line )
        pretty_print( line, fout )
    end
end

def do_name_mappings( line )
    for mapping_from in mapping_keys_sorted_longest_first
        line.gsub!( mapping_from, $mappings[mapping_from] )
    end
    line.gsub!( /(\w)_(\w)/, '\1-\2' )
    return line
end

def mapping_keys_sorted_longest_first
    return $mappings.keys.sort_by { |m| m.length }.reverse
end

def print_keywords( fout )
    pretty_print( '', fout )
    pretty_print( ';; Keywords', fout )
    for kw in $keywords.keys().sort
        pretty_print( $keywords[kw], fout )
    end
end

def print_referenced_rfc5234_rules( fout )
    rfc5234_core_rules = [
        'ALPHA          =  %x41-5A / %x61-7A   ; A-Z / a-z',
        'CR             =  %x0D         ; carriage return',
        'DIGIT          =  %x30-39      ; 0-9',
        # 'DQUOTE         =  %x22         ; " (Double Quote)',
        'HEXDIG         =  DIGIT / "A" / "B" / "C" / "D" / "E" / "F"',
        'HTAB           =  %x09         ; horizontal tab',
        'LF             =  %x0A         ; linefeed',
        'SP             =  %x20         ; space',
        'WSP            =  SP / HTAB    ; white space'
        ]
    pretty_print( '', fout )
    pretty_print( ';; Referenced RFC 5234 Core Rules', fout )
    for rule in rfc5234_core_rules
        pretty_print( rule, fout )
    end
end

def pretty_print( line, fout )
    if is_blank_line?( line )
        fout.write( "\n" )
    else
        fout.write( ' ' * $margin )
        if is_block_comment?( line )
            fout.write( line + "\n" )
        elsif comment = local_comment( line )
            fout.write( ' ' * $indent + comment + "\n" )
        elsif mapping = abnf_mapping( line )
            name, expansion = mapping
            equals = ' = '
            padding_needed = [ $indent - (name.length + equals.length), 0 ].max
            padding = ' ' * padding_needed
            fout.write( name + padding + equals + expansion + "\n" )
        else
            fout.write( ' ' * $indent + line + "\n" ) # A 2nd/3rd expression line
        end
    end
end

def is_blank_line?( line )
    return /^\s*$/.match( line )
end

def is_block_comment?( line )
    return /^\s*;;/.match( line )
end

def local_comment( line )
    return (m = /^\s*(;.*)/.match( line )) ? m[1] : false
end

def abnf_mapping( line )
    return (m = /([\w_\-]+)\s*=\s*(.*)/.match( line )) ? [m[1], m[2]] : false
end

main
