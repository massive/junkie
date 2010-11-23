require 'lib/junkie'

Junkie.configure do |config|
   config.app_key = '6ac7fe813e89aead20e9'
   config.log_level = :debug
end

EventMachine.run do
  client = Junkie::Client.create
  
  client.subscribe(:channel => 'test_channel')
  
  client.bind(:my_event) do |event|
    puts "my event"
    puts event.inspect
  end
  
  client.bind(:other_event) do |event|
    puts "other event"
    puts event.inspect
  end
  
  client.bind(:__pusher__) do
    puts "pusher"
  end
  
  client.bind('*') do |event|
    puts "global"
    puts event.inspect
  end
  
  client.error do |event|
    puts "Err"
  end
  
  client.disconnect do |event|
    puts "Disconnect"
  end
end