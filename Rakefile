require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "textquery"
    gemspec.summary = "Evaluate any text against a collection of match rules"
    gemspec.description = gemspec.summary
    gemspec.email = "ilya@igvita.com"
    gemspec.homepage = "http://github.com/igrigorik/textquery"
    gemspec.authors = ["Ilya Grigorik"]
    gemspec.add_dependency("treetop")
    gemspec.rubyforge_project = "textquery"
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
