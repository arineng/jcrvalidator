# JSON Content Rules Validator

## Background

JSON Content Rules (JCR) is a JSON-specific schema language. JCR was created by ARIN in an effort
to better describe JSON structures in RDAP.

The current version of the JCR specification can be found here:
http://tools.ietf.org/html/draft-newton-json-content-rules-04

Comparison of proposed JSON schema languages:

* JSON Content Rules - JCR is not JSON, but it is a JSON-like syntax designed to be more compact
for the express purpose of describing JSON structures and content. It is not intended to describe
any other serialization format or describe any other aspect of a JSON-using protocol.
* PROTOGEN - An abstraction syntax capable of describing JSON, XML, ASN.1, and RFC 822 MIME.
* CBOR Data Definition Lanuage (CDDL) - CDDL describes structures in CBOR, a binary serialization
format that is a data model superset of JSON. Therefore a profile of CDDL should be capable of
describing JSON.
* JSON Schema - Unlike JCR, JSON Schema is JSON, and is consequently more verbose than JCR. JSON
Schema also has mechanisms for describing hyper-linking applications.

## Status

At present, this is just proof-of-concept software meant to prove out the JSON Content Rules (JCR)
syntax. Once the JCR syntax specification is finalized, validation of JSON against JCR will be added.

## Usage

This code is written in Ruby using Parslet. You will need to install Parslet. The easiest way to do
that is via gem. This code was written and tested on Ruby 2.0. At present it can only run its unit
tests. Feel free to fiddle with it.

To run the unit tests, simply run the `rspec` command.

To parse a set of rules: `bin/jcr example.jcr`. If successfully parsed, it will print out a set of
named rules. Otherwise you'll get a parse tree that attempts to be helpful about what went wrong.
