require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc "this is the default"
task :default do
  puts "Hello World!"
end

desc "test command line examples"
task :test_cli do
  sh "cd examples; bash examples.sh -n"
end