#@IgnoreInspection BashAddShebang
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


# Pass JSON into the JCR validator against a ruleset given on the command line
# from JSON given in standard input
# This one should succeed
echo
echo "[ 1, 2]" | jcr -v -R "[ *:integer ]"
if [ $? != 0 ]; then
  echo "** Unexpected return value"
fi

# Pass JSON into the JCR validator against a ruleset given on the command line
# from JSON given on the command line
# This one should succeed
echo
jcr -v -R "[ *:integer ]" -J "[ 1, 2]"
if [ $? != 0 ]; then
  echo "** Unexpected return value"
fi

# Pass JSON into the JCR validator against a ruleset given on the command line
# This one should fail
echo
echo "[ 1, 2]" | jcr -v -R "[ *:string ]"
if [ $? != 1 ]; then
  echo "** Unexpected return value"
else
  echo "Failed to validate - this is expected"
fi

# Pass JSON into the JCR validator from a file with a ruleset specified in a file
# This one should succeed
echo
jcr -v -r example1.jcr example1a.json
if [ $? != 0 ]; then
  echo "** Unexpected return value"
fi

# Pass JSON into the JCR validator from a file with a ruleset specified in a file
# This one should succeed
echo
jcr -v -r example1.jcr example1b.json
if [ $? != 0 ]; then
  echo "** Unexpected return value"
fi

# Pass multiple JSON files into the JCR validator using a ruleset specified in a file
echo
jcr -v -r example1.jcr example1*.json
if [ $? != 0 ]; then
  echo "** Unexpected return value"
fi

# Override a rule from the command line
# Should succeed
echo
jcr -v -r example1.jcr -O "my_integers :0..2" example1a.json
if [ $? != 0 ]; then
  echo "** Unexpected return value"
fi

# Override a rule from the command line
# Should fail
echo
jcr -v -r example1.jcr -O "my_integers :0..2" example1b.json
if [ $? != 1 ]; then
  echo "** Unexpected return value"
else
  echo "Failed to validate - this is expected"
fi

# Override a rule from a file
# Should succeed
echo
jcr -v -r example1.jcr -o example1_override.jcr example1a.json
if [ $? != 0 ]; then
  echo "** Unexpected return value"
fi

# Override a rule from a file
# Should fail
echo
jcr -v -r example1.jcr -o example1_override.jcr example1b.json
if [ $? != 1 ]; then
  echo "** Unexpected return value"
else
  echo "Failed to validate - this is expected"
fi

