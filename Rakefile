=begin

    This file is part of the Raktr project and may be subject to
    redistribution and commercial restrictions. Please see the Raktr
    web site for more information on licensing and terms of use.

=end

require 'rubygems'
require File.expand_path( File.dirname( __FILE__ ) ) + '/lib/raktr/version'

begin
    require 'rspec'
    require 'rspec/core/rake_task'

    RSpec::Core::RakeTask.new
rescue
end

task default: [ :build, :spec ]

desc 'Generate docs'
task :docs do
    outdir = '../raktr-docs'
    sh "rm -rf #{outdir}"
    sh "mkdir -p #{outdir}"

    sh "yardoc -o #{outdir}"

    sh 'rm -rf .yardoc'
end

desc 'Clean up'
task :clean do
    sh 'rm *.gem || true'
end

desc 'Build the gem.'
task build: [ :clean ] do
    sh "gem build raktr.gemspec"
end

desc 'Build and install the gem.'
task install: [ :build ] do
    sh "gem install raktr-#{Raktr::VERSION}.gem"
end

desc 'Push a new version to Rubygems'
task publish: [ :build ] do
    sh "git tag -a v#{Raktr::VERSION} -m 'Version #{Raktr::VERSION}'"
    sh "gem push raktr-#{Raktr::VERSION}.gem"
end
task release: [ :publish ]
