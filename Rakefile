require 'gemmer'

Gemmer::Tasks.new('metafun') do |t|
  t.release_via :rubygems
end

require 'rake'
require 'rake/testtask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the metafun plugin unit tests.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

namespace :test do
  desc 'Measures test coverage'
  task :coverage do
    rm_f "coverage"
    rm_f "coverage.data"
    rcov = "rcov --rails --aggregate coverage.data --text-summary --exclude \"gems/*,rubygems/*,rcov*\" -Ilib"
    system("#{rcov} --html #{Dir.glob('test/**/*_test.rb').join(' ')}")
    system("open coverage/index.html") if PLATFORM['darwin']
  end
end
