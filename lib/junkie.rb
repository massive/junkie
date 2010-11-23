$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require "bundler/setup"

require 'eventmachine'
require 'em-http-request'
require 'json'
require 'logging'
require 'hashie'
require 'pp'

require 'junkie/lib/config'
require 'junkie/lib/client'

module Junkie
  extend Configuration
end