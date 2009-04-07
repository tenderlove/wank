# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/wank/version.rb'
require "rake/extensiontask"

HOE = Hoe.new('wank', Wank::VERSION) do |p|
  p.developer('Aaron Patterson', 'aaronp@rubyforge.org')

  p.extra_deps      = [['nokogiri', '>= 1.3.0']]
  p.extra_dev_deps  << "rake-compiler"
end

Rake::ExtensionTask.new("wank", HOE.spec)

# vim: syntax=Ruby
