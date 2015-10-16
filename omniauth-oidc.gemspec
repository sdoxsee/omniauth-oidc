# -*- encoding: utf-8 -*-
require File.expand_path(File.join('..', 'lib', 'omniauth', 'oidc', 'version'), __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "omniauth-oidc"
  gem.version       = OmniAuth::Oidc::VERSION
  gem.license       = 'MIT'
  gem.summary       = %q{An OpenID Connect strategy for OmniAuth 1.x}
  gem.description   = %q{An OpenID Connect strategy for OmniAuth 1.x}
  gem.authors       = ["Stephen Doxsee"]
  gem.homepage      = "https://github.com/sdoxsee/omniauth-oidc"

  gem.files         = `git ls-files`.split("\n")
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'omniauth', '>= 1.1.1'
  gem.add_runtime_dependency 'omniauth-oauth2', '>= 1.1.1'
  gem.add_runtime_dependency 'jwt', '~> 1.0'
  gem.add_runtime_dependency 'multi_json', '~> 1.3'
  gem.add_runtime_dependency 'addressable', '~> 2.3'

  gem.add_development_dependency 'rspec', '>= 2.14.0'
  gem.add_development_dependency 'rake'
end
