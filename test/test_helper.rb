require File.expand_path('../../lib/traffiq', __FILE__)
require 'minitest/autorun'
require 'mocha/mini_test'

def context(name, &block)
  describe(name, &block)
end
