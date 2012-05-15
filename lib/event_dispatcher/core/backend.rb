module EventDispatcher::Core

  class Backend

    class << self
      def dispatch(events, actor, subject, extras = {})
        # load all rules that have the associated trigger
        klass_trigger = {}

        # add an all event so that triggers that listen to all always get fired
        events << :all

        get_applicable_triggers(events).each { |klass|
          klass_trigger[klass::ENTITY_TYPE] = klass
        }

        current_logger = nil
        if (extras[:session_id])
          current_logger = get_logger(extras[:session_id])
        else
          current_logger = get_logger("unknown")
        end

        current_logger.log "Event #{events.to_s} received ... " if current_logger

        rules = get_built_in_rules(current_logger)
        get_active_rules(klass_trigger, rules)

        rules.each do |id, rule|
          rule.execute(events, actor, subject, extras) if rule.enabled?
        end

        true
      end

      def config
        @config
      end

      def config=(config)
        @config = config
      end

      def get_built_in_rules(logger = nil)
        rules = {}
        if (@config && @config.disable_all)
          EventDispatcher::EventRuleBase.subclasses.each do |klass|
            new_logger = logger.logger("#{klass.to_s} > ") if logger
            rules[klass.to_s] = klass.new(new_logger) if in_enabled_list?(klass)
          end
        else
          EventDispatcher::EventRuleBase.subclasses.each do |klass|
            new_logger = logger.logger("#{klass.to_s} > ") if logger
            rules[klass.to_s] = klass.new(new_logger) unless in_disabled_list?(klass)
          end
        end

        rules
      end

      protected

      def get_logger(session_id)
        if @config && @config.event_log
          logger_klass = @config.logger_backend
          return logger_klass.new(session_id)
        end
        nil
      end

      def in_enabled_list?(klass)
        if @config
          return  @config.enabled.include? klass.to_s.to_sym
        end
        false
      end

      def in_disabled_list?(klass)
        if @config
          return  @config.disabled.include? klass.to_s.to_sym
        end
        false
      end



      def get_active_rules(klass_trigger, rules, logger = nil)
        rule_triggers = RuleTrigger.where(trigger_type: klass_trigger.keys)

        rule_triggers.each do |t|
          rules[t.rule.id] = t.rule if t.rule.enabled?
        end
      end

      private

      def get_applicable_triggers(events)
        applicable_triggers = []
        EventDispatcher::Trigger.subclasses.each do |klass|
          applicable_triggers << klass if klass.responds_to_events? events
        end

        applicable_triggers
      end
    end
  end
end