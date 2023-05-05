# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pact/mock_service/version'

Gem::Specification.new do |gem|
  gem.name          = "pact-mock_service"
  gem.version       = Pact::MockService::VERSION
  gem.authors       = ["James Fraser", "Sergei Matheson", "Brent Snook", "Ronald Holshausen", "Beth Skurrie"]
  gem.email         = ["james.fraser@alumni.swinburne.edu", "sergei.matheson@gmail.com", "brent@fuglylogic.com", "uglyog@gmail.com", "beth@bethesque.com"]
  gem.summary       = %q{Provides a mock service for use with Pact}
  gem.homepage      = "https://github.com/bethesque/pact-mock_service"

  gem.required_ruby_version = '>= 2.0'

  gem.files         = Dir.glob("{bin,lib}/**/*") + Dir.glob(%w(Gemfile LICENSE.txt README.md CHANGELOG.md))

  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.license       = 'MIT'

  gem.add_runtime_dependency 'rack', '~> 2.0'
  gem.add_runtime_dependency 'rspec', '>=2.14'
  gem.add_runtime_dependency 'find_a_port', '~> 1.0.1'
  gem.add_runtime_dependency 'thor', '>= 0.19', '< 2.0'
  gem.add_runtime_dependency 'json'
  gem.add_runtime_dependency 'webrick', '~> 1.3'
  gem.add_runtime_dependency 'term-ansicolor', '~> 1.0'
  gem.add_runtime_dependency 'pact-support', '~> 1.16', '>= 1.16.4'
  gem.add_runtime_dependency 'filelock', '~> 1.1'

  gem.add_development_dependency 'rack-test', '~> 0.7'
  gem.add_development_dependency 'rake', '~> 13.0', '>= 13.0.1'
  gem.add_development_dependency 'webmock', '~> 3.4'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'fakefs', '~> 2.4'
  gem.add_development_dependency 'hashie', '~> 2.0'
  gem.add_development_dependency 'activesupport', '~> 5.1'
  gem.add_development_dependency 'faraday', '~> 0.12'
  gem.add_development_dependency 'octokit', '~> 4.7'
  gem.add_development_dependency 'conventional-changelog', '~> 1.3'
  gem.add_development_dependency 'bump', '~> 0.5'
end
