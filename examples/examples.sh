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
# This one should succeed
echo "[ 1, 2]" | jcr -v -R "[ *:integer ]"

# Pass JSON into the JCR validator against a ruleset given on the command line
# This one should fail
echo "[ 1, 2]" | jcr -v -R "[ *:string ]"

# Pass JSON into the JCR validator from a file with a ruleset specified in a file
# This one should succeed
jcr -v -r example1.jcr example1a.json

# Pass JSON into the JCR validator from a file with a ruleset specified in a file
# This one should succeed
jcr -v -r example1.jcr example1b.json

# This isn't possible because the globbing concatentates the files, which is not JSON legal
# jcr -v -r example1.jcr example1*.json

# Override a rule from the command line
# Should succeed
jcr -v -r example1.jcr -O "my_integers :0..2" example1a.json

# Override a rule from the command line
# Should fail
jcr -v -r example1.jcr -O "my_integers :0..2" example1b.json

# Override a rule from a file
# Should succeed
jcr -v -r example1.jcr -o example1_override.jcr example1a.json

# Override a rule from a file
# Should fail
jcr -v -r example1.jcr -o example1_override.jcr example1b.json
