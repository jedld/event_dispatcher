require 'spec_helper'

describe EventDispatcher::MemcacheEventLog do
  let(:session_id) {"12345677"}

  reset_cache_every_time

  before do
    @memcache_logger = EventDispatcher::MemcacheEventLog.new(session_id)
  end


  describe "#log" do
    it "logs the event" do
      @memcache_logger.log("event number one")
    end

    it "returns the events that were logged" do
      @memcache_logger.to_a.should == []
      @memcache_logger.log("event number one")
      @memcache_logger.to_a.first.should match "event number one"
      @memcache_logger.log("event number two")
      @memcache_logger.to_a.first.should match "event number one"
      @memcache_logger.to_a.second.should match "event number two"
    end

    it "doesn't exceed max entries" do
      memcache_logger = EventDispatcher::MemcacheEventLog.new(session_id,'',10)
      15.times do |i|
        memcache_logger.log("#{i}")
      end
      memcache_logger.to_a.count.should == 10
    end

    it "should just fall off after an hour" do
      @memcache_logger.to_a.should == []
      @memcache_logger.log("event number one")
      Timecop.travel(1.hour.from_now) do
        @memcache_logger.to_a.should == []
      end
    end

    it "stores in separate lists depending on the session_id" do
      memcache_logger_1 = EventDispatcher::MemcacheEventLog.new("_session1")
      memcache_logger_2 = EventDispatcher::MemcacheEventLog.new("_session2")
      memcache_logger_1.log("testing session1")
      memcache_logger_2.log("testing session2")
      memcache_logger_1.to_a.count.should == 1
      memcache_logger_2.to_a.count.should == 1

    end
  end

  describe "#clear" do
    before do
      @memcache_logger.log("event number one")
    end

    it "clears all events" do
      @memcache_logger.to_a.first.should match "event number one"
      @memcache_logger.clear
      @memcache_logger.to_a.should == []
    end
  end

end