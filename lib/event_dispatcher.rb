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
  if defined?(Rails)
    require 'rails/generators'
    require "event_dispatcher/core/engine"
    require "event_dispatcher/generators/action/action_generator"
    require "event_dispatcher/generators/rule/rule_generator"
    require "event_dispatcher/generators/trigger/trigger_generator"
  end


end
