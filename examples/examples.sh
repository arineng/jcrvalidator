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

# If you have not installed this software with a gem, you may need to add the
# 'jcr' command to your execution path.
export PATH=$PATH:../bin

VF="-v"
args="$(getopt -n "$0" -l no-verbose n $*)" \
|| exit -1
for arg in $args; do
    case "$arg" in
        -n|--no-verbose)
            VF="";;
    esac
done

# assert.sh is an assertion library for bash that makes this more readable
# and testable.
# wget https://raw.github.com/lehmannro/assert.sh/v1.1/assert.sh
. assert.sh -v

# Pass JSON into the JCR validator against a ruleset given on the command line
# from JSON given in standard input
# This one should succeed
echo "[ 1, 2]" | jcr $VF -R "[ integer * ]"
assert "echo $?" 0

# Pass JSON into the JCR validator against a ruleset given on the command line
# from JSON given on the command line
# This one should succeed
jcr $VF -R "[ integer * ]" -J "[ 1, 2]"
assert "echo $?" 0

# Pass JSON into the JCR validator against a ruleset given on the command line
# This one should fail
echo "[ 1, 2]" | jcr $VF -R "[ string * ]"
assert "echo $?" 3

# Pass JSON into the JCR validator from a file with a ruleset specified in a file
# This one should succeed
jcr $VF -r example1.jcr example1a.json
assert "echo $?" 0

# Pass JSON into the JCR validator from a file with a ruleset specified in a file
# This one should succeed
jcr $VF -r example1.jcr example1b.json
assert "echo $?" 0

# Pass multiple JSON files into the JCR validator using a ruleset specified in a file
jcr $VF -r example1.jcr example1*.json
assert "echo $?" 0

# Override a rule from the command line
# Should succeed
jcr $VF -r example1.jcr -O "\$my_integers =:0..2" example1a.json
assert "echo $?" 0

# Override a rule from the command line
# Should fail
jcr $VF -r example1.jcr -O "\$my_integers =:0..2" example1b.json
assert "echo $?" 3

# Override a rule from a file
# Should succeed
jcr $VF -r example1.jcr -o example1_override.jcr example1a.json
assert "echo $?" 0

# Override a rule from a file
# Should fail
jcr $VF -r example1.jcr -o example1_override.jcr example1b.json
assert "echo $?" 3

assert_end examples