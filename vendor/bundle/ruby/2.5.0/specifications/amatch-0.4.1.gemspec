# -*- encoding: utf-8 -*-
# stub: amatch 0.4.1 ruby lib ext
# stub: ext/extconf.rb

Gem::Specification.new do |s|
  s.name = "amatch".freeze
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze, "ext".freeze]
  s.authors = ["Florian Frank".freeze]
  s.date = "2022-05-15"
  s.description = "Amatch is a library for approximate string matching and searching in strings.\nSeveral algorithms can be used to do this, and it's also possible to compute a\nsimilarity metric number between 0.0 and 1.0 for two given strings.\n".freeze
  s.email = "flori@ping.de".freeze
  s.executables = ["agrep".freeze, "dupfind".freeze]
  s.extensions = ["ext/extconf.rb".freeze]
  s.extra_rdoc_files = ["README.md".freeze, "lib/amatch.rb".freeze, "lib/amatch/polite.rb".freeze, "lib/amatch/rude.rb".freeze, "lib/amatch/version.rb".freeze, "ext/amatch_ext.c".freeze, "ext/pair.c".freeze]
  s.files = ["README.md".freeze, "bin/agrep".freeze, "bin/dupfind".freeze, "ext/amatch_ext.c".freeze, "ext/extconf.rb".freeze, "ext/pair.c".freeze, "lib/amatch.rb".freeze, "lib/amatch/polite.rb".freeze, "lib/amatch/rude.rb".freeze, "lib/amatch/version.rb".freeze]
  s.homepage = "http://github.com/flori/amatch".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.rdoc_options = ["--title".freeze, "Amatch - Approximate Matching".freeze, "--main".freeze, "README.md".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.4".freeze)
  s.rubygems_version = "3.2.3".freeze
  s.summary = "Approximate String Matching library".freeze

  s.installed_by_version = "3.2.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<gem_hadar>.freeze, ["~> 1.12.0"])
    s.add_development_dependency(%q<test-unit>.freeze, ["~> 3.0"])
    s.add_development_dependency(%q<all_images>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<tins>.freeze, ["~> 1.0"])
    s.add_runtime_dependency(%q<mize>.freeze, [">= 0"])
  else
    s.add_dependency(%q<gem_hadar>.freeze, ["~> 1.12.0"])
    s.add_dependency(%q<test-unit>.freeze, ["~> 3.0"])
    s.add_dependency(%q<all_images>.freeze, [">= 0"])
    s.add_dependency(%q<tins>.freeze, ["~> 1.0"])
    s.add_dependency(%q<mize>.freeze, [">= 0"])
  end
end
