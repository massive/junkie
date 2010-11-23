module Junkie
  module Configuration
    
    OPTIONS = [:app_key, :pusherapp_url, :log_level]
    attr_accessor *OPTIONS
    
    DEFAULT_OPTIONS = {
      :pusherapp_url => 'ws.pusherapp.com',
      :log_level => :warn
    }
    
    def metaclass
      (class << self; self; end)
    end
    
    def configure
      yield self
    end
    
    def options
      OPTIONS.inject({}) do |acc, key|
        acc[key] = send(key)
        acc
      end
    end    
  end
end