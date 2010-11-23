module Junkie
  class Client    
    attr_accessor :event_stack, :logger, :socket, :channels
    attr_accessor *Configuration::OPTIONS
     
    def initialize
      @event_stack = Hash.new { |hash, key| hash[key] = [] }
      @channels = []
      load_options
      @logger = Logging.logger(STDOUT)
    end
    
    def self.create
      self.new.tap do |o|
        o.connect
      end
    end
    
    def connect
      @socket = EventMachine::HttpRequest.new("ws://#{pusherapp_url}/app/#{app_key}").get :timeout => 0
      logger.info "Connected to Pusherapp. URI ws://#{pusherapp_url}/app/#{app_key}"
      attach_callbacks_to_socket
    end
    
    def load_options
      Junkie.options.each_pair do |k, v|
        send(:"#{k}=", v || Configuration::DEFAULT_OPTIONS[k])
      end
    end    
    
    def process_stream_input(input)
      payload = Hashie::Mash.new JSON.parse(input)
      run_callbacks_for_event(payload)
    end

    def run_callbacks_for_event(payload)
      event_stack[payload.event.to_sym].each { |callback| callback.call(payload) }
      event_stack[:*].each { |callback| callback.call(payload) }
      if payload.event.match /pusher:\w*/
        event_stack[:__pusher__].each { |callback| callback.call(payload) }        
      end
    end    
    
    def send_subscription(channel)
      socket.send({:event => 'pusher:subscribe', :data => {:channel => channel}}.to_json)
      logger.info "Subscribed to channel #{channel}"      
    end
          
    def attach_callbacks_to_socket
      socket.callback {
        channels.each do |channel|
          send_subscription(channel)
        end
      }
      socket.stream { |input|
        process_stream_input(input)
      }
    end
    
    def subscribe(opts = {})
      channels << opts[:channel]
      send_subscription(opts[:channel]) if socket
    end
    
    def bind(event_name, &block)
      logger.info "Bound callback ##{event_stack[event_name].size} for event #{event_name}"
      event_stack[event_name.to_sym].push block
    end
    
    def disconnect(&block)
      socket.disconnect &block
    end
    
    def error(&block)
      socket.errback &block
    end
  end
end