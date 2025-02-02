# frozen_string_literal: true

require_relative "lib/demo/app/version"

Gem::Specification.new do |spec|
  spec.name = "demo-app"
  spec.version = Demo::App::VERSION
  spec.authors = ["Michael Greenly"]
  spec.email = ["mgreenly@gmail.com"]

  spec.summary = "A dummy app to demonstrate the a2i process"

  gemspec = File.basename(__FILE__)
  spec.files = Dir['lib/**/*.rb', 'exe/*', 'bin/*']
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Bundler should match your installed version
  spec.add_runtime_dependency "bundler", "= 2.6.3"

  # all other gems should be pinned to minor versions if
  # the gem correctly follows semantic versioning
  spec.add_runtime_dependency "rake", "~> 13.0"
  spec.add_runtime_dependency "mysql2", "~> 0.5"
end
