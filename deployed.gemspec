# frozen_string_literal: true

require_relative 'lib/deployed/version'

Gem::Specification.new do |spec|
  spec.name        = 'deployed'
  spec.version     = Deployed::VERSION
  spec.authors     = ['Simon Chiu']
  spec.email       = ['simon@furvur.com']
  spec.homepage    = 'https://github.com/geetfun/deployed'
  spec.summary     = 'Mountable Rails engine to manage Kamal commands'
  spec.description = 'Mountable Rails engine to manage Kamal commands'
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/geetfun/deployed'
  spec.metadata['changelog_uri'] = 'https://github.com/geetfun/deployed'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency 'kamal', '~> 1.0'
  spec.add_dependency 'turbo-rails', '~> 1.5'
  spec.add_dependency 'rails', '>= 7.1.1'
end
