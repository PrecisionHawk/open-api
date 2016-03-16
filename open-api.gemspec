lib = File.expand_path("../lib", __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name = 'open-api'
  s.version = '0.8.1'
  s.summary = 'Inline Openi API documentation for Ruby on Rails'
  s.description = 'Provides the ability to specify Open API documentation inline within the ' \
      'source code of your Ruby on Rails project, utilizing a rake task to generate / maintain ' \
      'that documentation as required.'
  s.licenses = ['Apache 2']
  s.authors = ['Matthew Mead']
  s.email = 'm.mead@precisionhawk.com'

  s.files = Dir.glob("{lib,spec,config}/**/*")
  s.files += %w(open-api.gemspec README.md)

  s.require_path = "lib"

  s.add_dependency "rails", ">= 4.0"

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl"
end
