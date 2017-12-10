# Copyright (c) 2017 American Registry for Internet Numbers
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

module JCR

  # This class extracts parts of a JCR file into multiple files based
  # on comments in the file. It can also create a new file without the
  # comments. This is useful for JCR going into specification documents
  # where it is nice to break the JCR up for illustrative purposes in
  # the specification but to also have one JCR file for programmatic
  # testing purposes.
  #
  # The file parts are extracted using the comments
  #   ; start_part FILENAME
  # and
  #   ; end_part
  # The comments must also be the only thing present on the line
  # though leading whitespace is allowed if desired.
  #
  # To get a new file with all parts be these comments, use this
  #   ; all_parts FILENAME

  class JcrParts

    # Determines if the the line is a start_part comment.
    # Return the file name otherwise nil
    def get_start( line )
      retval = nil
      m = /^\s*;\s*start_part\s*(.+)[^\s]*/.match( line )
      if m && m[1]
        retval = m[1]
      end
      return retval
    end

    # Determines if the the line is an all_parts comment.
    # Return the file name otherwise nil
    def get_all( line )
      retval = nil
      m = /^\s*;\s*all_parts\s*(.+)[^\s]*/.match( line )
      if m && m[1]
        retval = m[1]
      end
      return retval
    end

    # Determines if the the line is an end_parts comment.
    # Return true otherwise nil
    def get_end( line )
      retval = nil
      m = /^\s*;\s*end_part/.match( line )
      if m
        retval = true
      end
      return retval
    end

    # processes the lines
    # ruleset is to be a string read in using File.read
    def process_ruleset( ruleset )
      all_file_names = []
      all_parts = []
      all_parts_name = nil
      current_part = nil
      current_part_name = nil
      ruleset.lines do |line|
        if !all_parts_name && ( all_parts_name = get_all( line ) )
          all_file_names << all_parts_name
        elsif ( current_part_name = get_start( line ) )
          if current_part
            current_part.close
          end
          current_part = File.open( current_part_name, "w" )
          all_file_names << current_part_name
        elsif get_end( line ) && current_part
          current_part.close
          current_part = nil
        elsif current_part
          current_part.puts line
          all_parts << line
        else
          all_parts << line
        end
      end
      if current_part
        current_part.close
      end
      if all_parts_name
        f = File.open( all_parts_name, "w" )
        all_parts.each do |line|
          f.puts( line )
        end
        f.close
      end
      if all_file_names.length
        xml_fn = File.basename( all_file_names[0],".*" ) + "_xml_entity_refs"
        xml_fn = File.join( File.dirname( all_file_names[0] ), xml_fn )
        xml = File.open( xml_fn, "w" )
        all_file_names.each do |fn|
          bn = File.basename( fn, ".*" )
          xml.puts( "<!ENTITY #{bn} PUBLIC '' '#{fn}'>")
        end
        xml.close
      end
    end

  end
end
