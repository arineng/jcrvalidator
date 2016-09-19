lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'jcr/version'

Gem::Specification.new do |s|
  s.name        = 'jcrvalidator'
  s.version     = JCR::VERSION
  s.date        = Date.today
  s.summary     = "JCR Validator"
  s.description = "A JSON Content Rules (JCR) Validator library and command line utility. Version 0.6.x is closely following -07 of the draft."
  s.authors     = ["Andrew Newton","Pete Cordell"]
  s.email       = 'andy@arin.net'
  s.files       = Dir["lib/**/*"].entries
  s.homepage    =
          'https://github.com/arineng/jcrvalidator'
  s.license       = 'ISC'
  s.executables << 'jcr'
  s.add_dependency 'parslet', ['~> 1.7']
  s.add_dependency 'addressable', [ '= 2.3.8']
  s.add_dependency 'email_address_validator', ['~> 2.0']
  s.add_dependency 'big-phoney', ['= 0.1.4']
end
