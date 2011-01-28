require 'rubygems'
require "bundler"
Bundler.setup

require 'rake'
require 'spec/rake/spectask'
require 'jeweler'

Jeweler::Tasks.new do |gemspec|
  gemspec.name = "indeed"
  gemspec.summary = "Api wrap from Indeed service http://indeed.com"
  gemspec.description = <<-EOI
Simple wrapper for JSON api provided by indeed.
Original documentation at:
http://www.indeed.com/jsp/apiinfo.jsp (Require authorization)
Support search jobs API 2.0 and get jobs API
  EOI
  gemspec.email = "agresso@gmail.com"
  gemspec.homepage = "http://github.com/railsware/indeed"
  gemspec.authors = ["Bogdan Gusiev"]
end

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

