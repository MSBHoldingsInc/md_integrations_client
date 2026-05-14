require_relative 'lib/md_integrations/version'

Gem::Specification.new do |spec|
  spec.name        = 'md_integrations_client'
  spec.version     = MdIntegrations::VERSION
  spec.authors     = ['Nitesh Varma']
  spec.email       = ['nitesh@rugiet.com']

  spec.summary     = 'Ruby client for the MD Integrations Partner API'
  spec.description = 'Internal Rugiet wrapper for the MD Integrations Partner API — patients, cases, offerings, messages, files, and webhook verification.'
  spec.homepage    = 'https://github.com/MSBHoldingsInc/md_integrations_client'
  spec.license     = 'UNLICENSED'

  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = Dir['lib/**/*.rb', 'README.md', 'LICENSE.txt', 'CHANGELOG.md']
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '>= 2.0', '< 3.0'
  spec.add_dependency 'faraday-multipart', '~> 1.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
end
