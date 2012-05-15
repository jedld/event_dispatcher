module EventDispatcher::Core

  class Engine


    def self.fire(events, actor, subject, extras = {})

      events = [events] unless events.is_a? Array
      dispatch_backend.dispatch(events, actor, subject, extras)
      events
    end

    def self.get_next_entity_type(object_klass)
      if object_klass.subclasses
        entity_type_id = 0
        object_klass.subclasses.each do |klass|
          entity_type_id = klass::ENTITY_TYPE if klass::ENTITY_TYPE > entity_type_id
        end
        entity_type_id + 1
      else
        1
      end
    end

    def self.get_events_listened_to
      events = []
      #get events listened to by triggers
      [EventDispatcher::Core::EventRuleBase, EventDispatcher::Core::Trigger].each do |k|
        k.descendants.each do |klass|
          klass_events = klass.send(:event_list)
          events+=klass_events.flatten if klass_events
        end
      end
      events.uniq
    end

    def self.get_rules_by_events(events)
      triggered_rules = []
      events -= [:none]
      events.each { |event|
        rules = []
        klass_trigger = {}

        Backend.send(:get_applicable_triggers, event).each { |klass|
          klass_trigger[klass::ENTITY_TYPE] = klass
        }

        db_rules = []
        Backend.send(:get_active_rules, klass_trigger, db_rules)
        db_rules.each { |db_rule|
          rules << db_rule.name if db_rule
        }

        EventDispatcher::Core::EventRuleBase.descendants.each do |k|
          rules << k.to_s if k.trigger_test([event])
        end
        triggered_rules << {event: event, rules: rules}
      }
      triggered_rules
    end

    def self.get_types(object_klass)
      force_load_classes
      if object_klass.subclasses
        object_klass.subclasses.each.collect do |klass|
          [klass.get_name, klass::ENTITY_TYPE]
        end
      else
        []
      end
    end

    def self.force_load_classes
      #WORK AROUND for the development environment we need to require to force eager loading since cache_classes=false
      {"/app/models/event_rules/*.rb"=>'EventRules', "/app/models/event_actions/*.rb"=>'EventActions', "/app/models/event_triggers/*.rb"=>'EventTriggers'}.each do |path, module_name|
        Dir[Rails.root.to_s + path].each do |file|
          klass_name = File.basename(file, ".rb")
          klass = "#{module_name}::#{klass_name.camelize}".constantize
          Rails.logger.error("force eager load #{klass.to_s}")
        end
      end unless Rails.application.config.cache_classes
    end

    def self.config(&block)
      if block_given?
        @config = Config.new
        yield(@config)
      end
    end

    def self.dispatch_backend
      @config = EVENT_DISPATCHER_CONFIG if @config.blank?
      if (@config && @config.dispatch_backend)
        @config.dispatch_backend.config = @config
        return @config.dispatch_backend
      end
      EventDispatcher::Backend.config = @config
      EventDispatcher::Backend
    end

  end
end