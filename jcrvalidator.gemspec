lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'jcrvalidator'
  s.version     = '0.5.0'
  s.date        = '2015-12-31'
  s.summary     = "JCR Validator"
  s.description = "A JSON Content Rules (JCR) Validator library and command line utility."
  s.authors     = ["Andrew Newton","Pete Cordell"]
  s.email       = 'andy@arin.net'
  s.files       = Dir["lib/**/*"].entries
  s.homepage    =
          'https://github.com/arineng/jcrvalidator'
  s.license       = 'ISC'
  s.executables << 'jcr'
end