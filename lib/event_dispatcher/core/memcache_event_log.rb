module EventDispatcher::Core

  class MemcacheEventLog
    attr_accessor :session_id, :namespace, :max_entries

    def initialize(session_id, namespace = "", max_entries = 100)
      @session_id = session_id
      self.max_entries = max_entries
      self.namespace = namespace
    end

    def logger(name)
        EventDispatcher::Core::MemcacheEventLog.new(session_id, "#{namespace} > #{name}")
    end

    def log(body_str)
      event_list = get_data(event_list_key)

      if (event_list.blank?)
        event_id = 0
        list = [0]
      else
        list = JSON.parse(event_list)
        list.shift if list.count >= max_entries
        event_id = list.last + 1
        list << event_id
      end

      event_item_key = "event_log_#{@session_id}_#{event_id}"
      expiration = 1.hour.seconds.to_i
      write_data(event_list_key, list.to_json, expiration)
      write_data(event_item_key, "#{Time.now.to_s} #{namespace} : #{body_str}", expiration)
    end

    def to_a
      event_list = get_data(event_list_key)
      return [] if event_list.blank?

      result = []
      list = JSON.parse(event_list)
      list.each do |item|
        event_item_key = "event_log_#{@session_id}_#{item}"
        result << get_data(event_item_key)
      end
      result
    end

    def clear
      Rails.cache.delete(event_list_key)
    end

    protected

    def event_list_key
      "event_log_master_#{@session_id}"
    end

    def get_data(key)
      Rails.cache.read(key)
    end

    def write_data(key, value, expiration)
      Rails.cache.write(key, value, {expires_in: expiration})
    end
  end
end