lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'jcr/version'
require 'date'

Gem::Specification.new do |s|
  s.name        = 'jcrvalidator'
  s.version     = JCR::VERSION
  s.date        = Date.today
  s.summary     = "JCR Validator"
  s.description = "A JSON Content Rules (JCR) Validator library and command line utility."
  s.authors     = ["Andrew Newton","Pete Cordell"]
  s.email       = 'andy@arin.net'
  s.files       = Dir["lib/**/*"].entries
  s.homepage    =
          'https://github.com/arineng/jcrvalidator'
  s.license       = 'ISC'
  s.executables << 'jcr'
  s.add_dependency 'parslet', ['~> 1.7']
  s.add_dependency 'addressable', [ '= 2.7.0']
  s.add_dependency 'email_address_validator', ['~> 2.0']
  s.add_dependency 'big-phoney', ['= 0.1.4']
end
