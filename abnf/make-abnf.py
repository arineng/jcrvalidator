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

import re

# Configuration
parslet_src_file = '../lib/jcr/parser.rb'
abnf_output_file = 'jcr-abnf.txt'
margin = 0
indent = 19
keyword_indent = 30

mappings = {}
lines = []
keywords = {}

def main() :
    read_parslet_def()
    write_abnf()

def read_parslet_def() :
    "Read the Parslet Ruby definition into mappings and lines"
    fin = open( parslet_src_file, 'r' )
    for line in fin :
        conditionally_grab_mapping( line )
        conditionally_grab_abnf( line )
        conditionally_grab_keywords( line )
    fin.close()

def conditionally_grab_mapping( line ) :
    "If a line is a mapping line, put mapping in mappings"
    res = re.search( '^\s*#/\s*([\w?]+)\s*->\s*(.*)', line )
    if res :
        key = res.group(1)
        value = res.group(2)
        mappings[key] = value

def conditionally_grab_abnf( line ) :
    "If a line is prototypical ABNF, grab it"
    res = re.search( '^\s*#!\s*(.*)', line )
    if res :
        lines.append( res.group(1) )

def conditionally_grab_keywords( line ) :
    "If a line is a keyword line, put mapping in keywords"
    res = re.search( '^\s*#>\s*([\w_\-]+kw)(\s*=\s*)"([^"]+)"', line )
    if res :
        name = res.group(1)
        equals = res.group(2)
        label = res.group(3)
        chars = [ ('%0.2X' % ord(c)) for c in label ]
        codes = ".".join( chars )
        comment_padding = ' ' * max( keyword_indent - 3*len(label), 0 )
        line = name + equals + '%x' + codes + comment_padding + ' ; "' + label + '"'
        keywords[name] = line

def write_abnf() :
    fout = open( abnf_output_file, 'w' )
    print_captured_abnf( fout )
    print_keywords( fout )
    print_referenced_rfc5234_rules( fout )
    fout.close()

def print_captured_abnf( file ) :
    for line in lines :
        line = do_name_mappings( line )
        pretty_print( line, file )

def do_name_mappings( line ) :
    for mapping_from in sorted( mappings.keys(), key=len, reverse=True ) :  # Make sure longest src mapping done first
        line = line.replace( mapping_from, mappings[mapping_from] )
    line = line.replace( '_', '-' )
    return line

def print_keywords( file ) :
    print( '', file=file )
    pretty_print( ';; Keywords', file )
    for kw in sorted( keywords.keys() ) :
        pretty_print( keywords[kw], file )

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

def print_referenced_rfc5234_rules( file ) :
    print( '', file=file )
    pretty_print( ';; Referenced RFC 5234 Core Rules', file )
    for rule in rfc5234_core_rules :
        pretty_print( rule, file )

def pretty_print( line, file ) :
    if re.search( '^\s*$', line ) :    # A blank line
        print( '', file=file )
        return
    print( ' ' * margin, file=file, end='' )
    if re.search( '^\s*;;', line ) :    # Block comment
        print( line, file=file )
        return
    res = re.search( '^\s*(;.*)', line )    # Local comment
    if res :
        print( ' ' * indent + res.group(1), file=file )
        return
    res = re.search( '([\w_\-]+)\s*=\s*(.*)', line )    # An expression
    if res :
        name = res.group(1)
        expansion = res.group(2)
        equals = ' = '
        padding_needed = max( indent - (len( name ) + len( equals )), 0 )
        padding = ' ' * padding_needed
        print( name + padding + equals + expansion, file=file )
        return
    print( ' ' * indent + line, file=file ) # A 2nd/3rd expression line

main()

