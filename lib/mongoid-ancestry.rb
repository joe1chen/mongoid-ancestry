require "active_support/concern"

module Mongoid
  def self.mongoid3?
    ::Mongoid.const_defined? :Observer # deprecated in Mongoid 4.x
  end

  def self.mongoid2?
    ::Mongoid.const_defined? :Contexts # deprecated in Mongoid 3.x
  end

  module Ancestry
    extend ActiveSupport::Concern

    autoload :ClassMethods,    'mongoid-ancestry/class_methods'
    autoload :Error,           'mongoid-ancestry/exceptions'

    included do
      cattr_accessor :base_class
      self.base_class = self
    end

    require 'mongoid-ancestry/instance_methods'
  end
end
