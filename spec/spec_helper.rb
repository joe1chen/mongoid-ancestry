require 'rubygems'
require 'bundler/setup'

require "database_cleaner/mongoid"
require 'rspec'
require 'mongoid'

require 'mongoid-ancestry'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Mongoid.configure do |config|
  name = "mongoid_ancestry_test"
  config.respond_to?(:connect_to) ? config.connect_to(name) : config.master = Mongo::Connection.new.db(name)
end

DatabaseCleaner[:mongoid].strategy = [:deletion]

RSpec.configure do |c|
  c.before(:each) { DatabaseCleaner.clean }
end

# RSpec 3 with the RSpec 2-era `should` syntax still enabled, so the existing specs run unchanged.
RSpec.configure do |c|
  c.expect_with(:rspec) { |e| e.syntax = [:should, :expect] }
  c.mock_with(:rspec) { |m| m.syntax = [:should, :expect] }
end
