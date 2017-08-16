require 'rspec/core/rake_task'
require 'bundler/gem_tasks'

RSpec::Core::RakeTask.new(:spec)

desc "by default run tests"
task :default => :test

desc "test command line examples"
task :test_cli do
  sh "cd examples; bash examples.sh -n"
end

desc "demonstrate command line examples"
task :demo_cli do
  sh "cd examples; bash examples.sh"
end

desc "run all tests"
task :test => [:spec, :test_cli, :test_ruby_examples ]

task :test_simple_rb do
  ruby "-Ilib examples/simple.rb"
end

task :test_override_rb do
  ruby "-Ilib examples/override.rb"
end

task :test_callback_rb do
  ruby "-Ilib examples/callback.rb"
end

desc "test example ruby scripts"
task :test_ruby_examples => [ :test_simple_rb, :test_override_rb, :test_callback_rb ]