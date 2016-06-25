# coding: utf-8
require File.expand_path('../lib/vagrant-hypconfigmgmt/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "vagrant-hypconfigmgmt"
  spec.version       = Vagrant::Hypconfigmgmt::VERSION
  spec.authors       = ["Rick van de Loo"]
  spec.email         = ["rick@byte.nl"]
  spec.description   = %q{Prompt to configure a hypernode-vagrant}
  spec.summary       = %q{Prompt to configure a hypernode-vagrant}
  spec.homepage      = "https://github.com/ByteInternet/hypernode-vagrant"
  spec.license       = "MIT"

  spec.files = `git ls-files`.split("\n")
  spec.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
end
