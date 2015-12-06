# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'log2irc/version'

Gem::Specification.new do |spec|
  spec.name          = 'log2irc'
  spec.version       = Log2irc::VERSION
  spec.authors       = ['l3akage']
  spec.email         = ['info@l3akage.de']
  spec.summary       = 'Send syslog messages to irc'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'syslog_protocol'
  spec.add_dependency 'string-irc'
  spec.add_dependency 'snmp'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'bundler', '~> 1.10'
end
