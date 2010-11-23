require "spec_helper"

describe Junkie::Client do  
  before do
    @client = Junkie::Client.new
  end
  
  context "events" do    
    it "should bind to pusher events" do
      test_event = nil
      callback = lambda { |payload| test_event = payload.event }
      @client.bind(:__pusher__, &callback)
      @client.process_stream_input({:event => 'pusher:foobar'}.to_json)
      @client.process_stream_input({:event => 'foobar'}.to_json)
      test_event.should == 'pusher:foobar'
    end
    
    it "should bind to global events" do
      test_event = []
      callback = lambda { |payload| test_event << payload.event }
      @client.bind(:*, &callback)
      @client.process_stream_input({:event => 'pusher:foobar'}.to_json)
      @client.process_stream_input({:event => 'foobar'}.to_json)
      test_event.should == ["pusher:foobar", "foobar"]
    end 
    
    it "should allow to bind many times to single event" do
      test_event = []
      callback = lambda { |payload| test_event << payload.event }
      @client.bind(:foobar, &callback)
      @client.bind(:foobar, &callback)
      @client.process_stream_input({:event => 'foobar'}.to_json)
      test_event.should == ["foobar", "foobar"]
    end    
  end
  
  context "subscription" do
    before do 
      @client.socket = mock(Socket)
    end

    it "should subscribe to pusherapp" do
      @client.socket.should_receive(:send).with({:event => 'pusher:subscribe', :data => {:channel => "test_channel"}}.to_json)
      @client.subscribe(:channel => "test_channel")
    end
  end
  
  context "socket" do
    before do 
      @client.socket = mock(Socket)
    end
    
    it "should accept callbacks to disconnect and error" do
      @client.socket.should_receive(:disconnect).once.and_yield()
      @client.socket.should_receive(:errback).once.and_yield()
      a = 0
      callback = lambda { a += 1 }
      @client.disconnect(&callback)
      @client.error(&callback)
      a.should == 2
    end
    
  end
end