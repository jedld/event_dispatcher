require "event_dispatcher/version"
require "event_dispatcher/core/backend"
require "event_dispatcher/core/config"
require "event_dispatcher/core/engine"
require "event_dispatcher/core/rule_object_helper"
require "event_dispatcher/core/event_action"
require "event_dispatcher/core/event_dispatcher_helper"
require "event_dispatcher/core/event_rule_base"
require "event_dispatcher/core/memcache_event_log"
require "event_dispatcher/core/resque_backend"
require "event_dispatcher/core/trigger"

module EventDispatcher

  module Models

  end

  if defined?(Rails)
    require 'rails/generators'
    require "event_dispatcher/core/engine"
    require "event_dispatcher/generators/action/action_generator"
    require "event_dispatcher/generators/rule/rule_generator"
    require "event_dispatcher/generators/trigger/trigger_generator"
    require "event_dispatcher/generators/install/install_generator"
    require "event_dispatcher/models/rule"
    require "event_dispatcher/models/rule_action"
    require "event_dispatcher/models/rule_parameter"
    require "event_dispatcher/models/rule_trigger"


    ActiveSupport.on_load(:action_controller) do
      include EventDispatcher::Core::EventDispatcherHelper
      require "event_dispatcher/controllers/event_log_controller"
    end

    ActiveSupport.on_load(:active_record) do
      include EventDispatcher::Core::EventDispatcherHelper
    end

  end

  class EventDispatcherTasks < Rails::Railtie
    rake_tasks do
      Dir[File.join(File.dirname(__FILE__), 'tasks/*.rake')].each { |f| load f }
    end
  end

end
