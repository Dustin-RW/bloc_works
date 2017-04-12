# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bloc_works/version'

Gem::Specification.new do |spec|
  spec.name          = "bloc_works"
  spec.version       = BlocWorks::VERSION
  spec.authors       = ["Dustin"]
  spec.email         = ["dustinwaggoner@comcast.net"]

  spec.summary       = %q{Learning Web Framework}
  spec.description   = %q{Rails inspired learning Web Framework}
  spec.homepage      = "https://github.com/Bloc/bloc_works"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rack", "~> 1.6"
  spec.add_development_dependency "rack-test", "~> 0.6"
  spec.add_development_dependency "test-unit", "~> 3.2"
  spec.add_runtime_dependency "erubis", "~>2.7"
  spec.add_runtime_dependency "bloc_record"
  spec.add_runtime_dependency "pry"


end
