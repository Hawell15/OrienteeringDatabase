# -*- encoding: utf-8 -*-
# stub: protocol 2.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "protocol".freeze
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Florian Frank".freeze]
  s.date = "2019-11-05"
  s.description = "This library offers an implementation of protocols against which you can check\nthe conformity of your classes or instances of your classes. They are a bit\nlike Java Interfaces, but as mixin modules they can also contain already\nimplemented methods. Additionaly you can define preconditions/postconditions\nfor methods specified in a protocol.\n".freeze
  s.email = "flori@ping.de".freeze
  s.extra_rdoc_files = ["README.rdoc".freeze, "lib/protocol.rb".freeze, "lib/protocol/core.rb".freeze, "lib/protocol/descriptor.rb".freeze, "lib/protocol/errors.rb".freeze, "lib/protocol/message.rb".freeze, "lib/protocol/method_parser/ruby_parser.rb".freeze, "lib/protocol/post_condition.rb".freeze, "lib/protocol/protocol_module.rb".freeze, "lib/protocol/utilities.rb".freeze, "lib/protocol/version.rb".freeze, "lib/protocol/xt.rb".freeze]
  s.files = ["README.rdoc".freeze, "lib/protocol.rb".freeze, "lib/protocol/core.rb".freeze, "lib/protocol/descriptor.rb".freeze, "lib/protocol/errors.rb".freeze, "lib/protocol/message.rb".freeze, "lib/protocol/method_parser/ruby_parser.rb".freeze, "lib/protocol/post_condition.rb".freeze, "lib/protocol/protocol_module.rb".freeze, "lib/protocol/utilities.rb".freeze, "lib/protocol/version.rb".freeze, "lib/protocol/xt.rb".freeze]
  s.homepage = "http://flori.github.com/protocol".freeze
  s.licenses = ["GPL-2".freeze]
  s.rdoc_options = ["--title".freeze, "Protocol - Method Protocols for Ruby Classes".freeze, "--main".freeze, "README.rdoc".freeze]
  s.rubygems_version = "3.2.3".freeze
  s.summary = "Method Protocols for Ruby Classes".freeze

  s.installed_by_version = "3.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<gem_hadar>.freeze, ["~> 1.9.1"])
    s.add_development_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_development_dependency(%q<test-unit>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<ruby_parser>.freeze, ["~> 3.0"])
  else
    s.add_dependency(%q<gem_hadar>.freeze, ["~> 1.9.1"])
    s.add_dependency(%q<simplecov>.freeze, [">= 0"])
    s.add_dependency(%q<test-unit>.freeze, [">= 0"])
    s.add_dependency(%q<ruby_parser>.freeze, ["~> 3.0"])
  end
end
