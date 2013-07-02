$:.unshift('lib')
require 'rubygems'
require 'rubygems/package_task'
require 'rake/clean'
require 'rdoc/task'
require 'spec/rake/spectask'
require 'statemachine'

PKG_NAME = "MINT-statemachine"
PKG_VERSION   = Statemachine::VERSION::STRING
PKG_TAG = Statemachine::VERSION::TAG
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"
PKG_FILES = FileList[
  '[A-Z]*',
  'lib/**/*.rb', 
  'spec/**/*.rb' 
]

task :default => :spec

desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

desc 'Generate RDoc'
rd = RDoc::Task.new do |rdoc|
  rdoc.options << '--title' << 'Statemachine' << '--line-numbers' << '--inline-source' << '--main' << 'README.rdoc'
  rdoc.rdoc_files.include('README.rdoc', 'CHANGES', 'lib/**/*.rb')
end
task :rdoc

spec = Gem::Specification.new do |s|
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.summary = Statemachine::VERSION::DESCRIPTION
  s.description = "The MINT Statemachine is a ruby library for building Finite State Machines, based on the Statemachine gem by Micah Martin."
  s.files = PKG_FILES.to_a
  s.require_path = 'lib'
  s.test_files = Dir.glob('spec/*_spec.rb')
  s.require_path = 'lib'
  s.author = "Sebastian Feuerstack"
  s.email = "Sebastian@Feuerstack.org"
  s.homepage = "http://www.multi-access.de"
  end
Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

def egrep(pattern)
  Dir['**/*.rb'].each do |fn|
    count = 0
    open(fn) do |f|
      while line = f.gets
        count += 1
        if line =~ pattern
          puts "#{fn}:#{count}:#{line}"
        end
      end
    end
  end
end

desc "create a gemspec file"
task :make_spec do
  File.open("#{PKG_NAME}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

desc "Look for TODO and FIXME tags in the code"
task :todo do
  egrep /(FIXME|TODO|TBD)/
end

task :release => [:clobber, :verify_committed, :verify_user, :verify_password, :spec, :publish_packages, :tag, :publish_website, :publish_news]

desc "Verifies that there is no uncommitted code"
task :verify_committed do
  IO.popen('svn stat') do |io|
    io.each_line do |line|
      raise "\n!!! Do a svn commit first !!!\n\n" if line =~ /^\s*M\s*/
    end
  end
end

