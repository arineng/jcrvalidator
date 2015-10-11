# JSON Content Rules Validator

## Background

JSON Content Rules (JCR) is a JSON-specific schema language. JCR was created by ARIN in an effort
to better describe JSON structures in RDAP.

At present, this software is ahead of the specification.
The current version of the JCR specification can be found here:
http://tools.ietf.org/html/draft-newton-json-content-rules-04

## Usage

Use bundler to install all the dependencies.

If you do not have bundler, it is simple to install:

```
$ gem install bundler
```

From there, tell bundler to go get the rest of the gems:

```
$ bundle install
```

Now you can validate JSON against JCR.

```
$ echo "[ 1, 2]" | bin/jcr -v -R "[ *:integer ]"
Success!

$ echo "[ 1, 2]" | bin/jcr -v -R "[ *:string ]"
Failure: ....

$ bin/jcr -v -r example.jcr example.json
Success!
```

This code was written and tested on Ruby 2.0. At present it can only run its unit
tests. Feel free to fiddle with it. To run the unit tests, simply run the `rspec` command.

