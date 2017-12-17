# JSON Content Rules Validator

[![Gem Version](https://badge.fury.io/rb/jcrvalidator.svg)](https://badge.fury.io/rb/jcrvalidator)
[![Build Status](https://travis-ci.org/arineng/jcrvalidator.svg)](https://travis-ci.org/arineng/jcrvalidator)
[![Dependency Status](https://gemnasium.com/badges/github.com/arineng/jcrvalidator.svg)](https://gemnasium.com/github.com/arineng/jcrvalidator)
[![Coverage Status](https://coveralls.io/repos/github/arineng/jcrvalidator/badge.svg?branch=master)](https://coveralls.io/github/arineng/jcrvalidator?branch=master)

## Background

JSON Content Rules (JCR) is a language for specifying and testing the interchange of data in JSON 
format used by computer protocols and processes.  The syntax of JCR is a superset of JSON
possessing the conciseness and utility that has made JSON popular. It was created by the 
American Registry for Internet Numbers (ARIN) in an effort to better describe the JSON structures 
in protocols such as RDAP.

### A First Example: Specifying Content

   The following JSON data describes a JSON object with two members,
   "line-count" and "word-count", each containing an integer.

      { "line-count" : 3426, "word-count" : 27886 }

   This is also JCR that describes a JSON object with a member named
   "line-count" that is an integer that is exactly 3426 and a member
   named "word-count" that is an integer that is exactly 27886.

   For a protocol specification, it is probably more useful to specify
   that each member is any integer and not specific, exact integers:

      { "line-count" : integer, "word-count" : integer }

   Since line counts and word counts should be either zero or a positive
   integer, the specification may be further narrowed:

      { "line-count" : 0.. , "word-count" : 0.. }
      
### A Second Example: Testing Content

   Building on the first example, this second example describes the same
   object but with the addition of another member, "file-name".

      {
        "file-name"  : "rfc7159.txt",
        "line-count" : 3426,
        "word-count" : 27886
      }

   The following JCR describes objects like it.

      {
        "file-name"  : string,
        "line-count" : 0..,
        "word-count" : 0..
      }


   For the purposes of writing a protocol specification, JCR may be
   broken down into named rules to reduce complexity and to enable re-use.  The following example takes the JCR from above and rewrites the
   members as named rules.

      {
        $fn,
        $lc,
        $wc
      }

      $fn = "file-name"  : string
      $lc = "line-count" : 0..
      $wc = "word-count" : 0..

   With each member specified as a named rule, software testers can
   override them locally for specific test cases.  In the following
   example, the named rules are locally overridden for the test case
   where the file name is "rfc4627.txt".

      $fn = "file-name"  : "rfc4627.txt"
      $lc = "line-count" : 2102
      $wc = "word-count" : 16714

   In this example, the protocol specification describes the JSON object
   in general and an implementation overrides the rules for testing
   specific cases.
   
### More Information on JCR

More information on JCR can be found at [json-content-rules.org](http://json-content-rules.org/). 
The current published specification is an IETF Internet Draft (I-D) versioned as -09,
This software closely tracks the -09 version, 
which can be found [here](https://raw.githubusercontent.com/arineng/jcr/09/draft-newton-json-content-rules-09.txt)
   
## Version History

* 0.5.0 - First test GEM push.
* 0.5.1 - First public beta.
  * Small fix to bin/jcr to capture exit codes properly
  * Small enhancement to bin/jcr to suck in multiple JSON files
  * At present, this software is ahead of the specification.
* 0.5.2 - Minor tweaks
  * Added -J command line option
  * Changed command line option -s to -S to be more consistent
  * Will no longer allow member rules to be root rules
  * More group rule checking (code was there, just wan't being invoked)
* 0.5.3 - Fixes to the gem dependencies
* 0.6.0 - Fixes from 0.5.3 plus closer tracking to -07
* 0.6.1 - Towards -07
  * Updates to track the latest release candidate of -07
  * Updated docs, tests, and build
* 0.6.2 - Update of repetition syntax going into -07
* 0.6.3 - XOR experimentation which was never merged
* 0.6.4 - Version that matches -07 of the draft specification
* 0.6.5 - Fixed a bug with roots and empty object and array rules
* 0.7.0
  * Tracks the -09 draft
  * Fixes to allow annotations for groups in arrays and objects
  * Text output is now proper JCR
  * Fixed issue with multiple files on the command line with MacOS
  * Support for Ruby 2.4
  * Dropped Ruby 1.8, 1.9, and 2.0. CI testing on:
    * Linux 2.1, 2.3, 2.4, and JRuby 9.1
    * OSX 2.3 and 2.4
  * Fixes to ABNF in multi-line directives
  * Much better CLI and programmatic validation failure information and structures 
  * Fixes to print errors when the JCR fails to parse
* 0.8.0 - Adds the --process-parts command line option
* 0.8.1
  * Various issues with stack traces at the command line instead of proper errors
  * --process-parts now takes an optional directory
  * --process-parts now creates an XML entity reference file snippet
  * override rules can now reference rules in the original ruleset
  * more readable failure report
  * more readable verbose messages
  * @{not} annotation on targer rules were not honored but now fixed
  * better checking for groups referenced from arrays and objects

The current version of the JCR specification can be found 
[here](https://raw.githubusercontent.com/arineng/jcr/07/draft-newton-json-content-rules.txt)
  
## Features

This JCR Validator can be used by other Ruby code directly, 
or it may be invoked on the command line using the `jcr` command.

The command line utility can be given specific override rulesets for 
the purposes of local testing. If no root rule is given, it will test against all roots.

The library has all the features of the command line utility, 
and also has the ability to allow for custom validation of rules using Ruby code.
  
## Installation

To install the JCR Validator:

```
gem install jcrvalidator
```

This code was written and tested on Ruby 2.1, 2.3, and 2.4. 

## Command Line Usage

You can find a bunch of command line examples in `examples/examples.sh`

Here are some quick nibbles:

```
$ echo "[ 1, 2]" | bin/jcr -v -R "[ integer * ]"
Success!

$ echo "[ 1, 2]" | bin/jcr -v -R "[ string * ]"
Failure: ....

$ bin/jcr -v -r example.jcr example.json
Success!

$ bin/jcr -h
HELP
----

Usage: jcr [OPTIONS] [JSON_FILES]

Evaluates JSON against JSON Content Rules (JCR).

If -J is not specified, JSON_FILES is used.
If JSON_FILES is not specified, standard input (STDIN) is used.

Use -v to see results, otherwise check the exit code.

Options
    -r FILE                          file containing ruleset
    -R STRING                        string containing ruleset. Should probably be quoted
        --test-jcr                   parse and test the JCR only
        --process-parts [DIRECTORY]  creates smaller files for specification writing
    -S STRING                        name of root rule. All roots will be tried if none is specified
    -o FILE                          file containing overide ruleset (option can be repeated)
    -O STRING                        string containing overide rule (option can be repeated)
    -J STRING                        string containing JSON to evaluate. Should probably be quoted
    -v                               verbose
    -q                               quiet
    -h                               display help

Return codes:
 0 = success
 1 = bad JCR parsing or other bad condition
 2 = invalid option or bad use of command
 3 = unsuccessful evaluation of JSON

JCR Version 0.8.1
```

## Usage as a Library

It is easy to call the JCR Validator from Ruby programs. The `examples` directory contains some good examples:

* `simple.rb` is a simple and basic example
* `override.rb` shows how to override specific rules in a ruleset.
* `callback.rb` demonstrates how to do custom validation with callbacks
* `trace_failures.rb` demonstrates how to access validation failure information

### Custom Validation Using Callbacks

The `callback.rb` demonstrates the usage of custom code for evaluation of rules. There are a few important things to note about how callbacks work:

1. The validator will first evaluate a rule with internal validation before calling the callback code. This means child rules are evaluated by the validators own internal logic before a callback is invoked, and also that a callback for a child rule is called before the callback for its parent.
2. Depending on the internal evaluation, the callback is either invoked at the `rule_eval_true` or `rule_eval_false` methods.
3. The callback can return a `JCR::Evaluation` object to signify if the evaluation passed or not.
4. If the callback simply returns true, this is turned into a `JCR::Evaluation` signifying a passed evaluation.
5. If the callback returns false or a string, this is turned into a `JCR::Evaluation` signifying a failed evaluation. In cases where a string is returned, the string is used as the reason for failing the evaluation.
6. For validation of rules inside arrays and objects, a failed evaluation will usually result in the terminating the evaluation of the rest of the sibling rules of the containing array or object.

## Using the `--process-parts` Option

The `--process-parts` option extracts parts of a JCR file into multiple files based
on comments in the file. It can also create a new file without the
comments. This is useful for rulesets going into specification documents
where it is nice to break the rulesets up for illustrative purposes in
the specification but to also have one JCR file for programmatic
testing purposes.

The file parts are extracted using the comments

    ; start_part FILENAME
    
and

    ; end_part
    
The comments must also be the only thing present on the line
though leading whitespace is allowed if desired.

To get a new file with all parts but these comments, use this

    ; all_parts FILENAME
    
The `--process-parts` parameter will also take an optional directory name where it
will write the files.

## Building

Use bundler to install all the dependencies.

If you do not have bundler, it is simple to install:

```
$ gem install bundler
```

From there, tell bundler to go get the rest of the gems:

```
$ bundle install
```

To run the unit tests:

```
$ bundle exec rake test
````
