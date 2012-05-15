EVENT_DISPATCHER_CONFIG = EventDispatcher::Core::Config.new.tap do |config|

  config.dispatch_backend = EventDispatcher::Core::Backend

  if Rails.env == 'development'
    config.event_log = true
  end

end
