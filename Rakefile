require 'rubygems'
require 'rake/testtask'
require 'yard'

task :default => :all

Rake::TestTask.new do |t|
  t.libs << 'test'
end

YARD::Rake::YardocTask.new do |t|
#    t.files   = ['lib/**/*.rb','bin/**/*.rb','LICENSE','README']
    t.files   = ['lib/**/*.rb','bin/**/*.rb']
end

task :gem do
    sh "gem build itunes-controller.gemspec"
end

desc "Execute all the build tasks"
task :all do
    Rake::Task['yard'].invoke
    Rake::Task['test'].invoke    
    Rake::Task['gem'].invoke    
end


