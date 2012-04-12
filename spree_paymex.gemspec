# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "spree_paymex/version"

Gem::Specification.new do |s|
  s.name        = "spree_paymex"
  s.version     = SpreePaymex::VERSION
  s.authors     = ["Calvin Tee"]
  s.email       = ["calvin@collectskin.com"]
  s.homepage    = "collectskin.com"
  s.summary     = %q{Alliance Bank Paymex integration}
  s.description = %q{Alliance Bank Paymex integration}

  s.rubyforge_project = "spree_paymex"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
