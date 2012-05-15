module EventDispatcher::Core

  class EventException < Exception

  end

  class RequiredParameterException < EventException

    def initialize(param)
      @param = param
    end

    def param
      @param
    end

  end

  class EventRuleBase

    extend RuleObjectHelper

    attr_accessor :logger

    def initialize(logger = nil)
      @logger = logger
    end

    #need to define this so that even in the development
    def self.inherited(subclass)
      if superclass.respond_to? :inherited
        superclass.inherited(subclass)
      end
      @subclasses ||= []
      @subclasses << subclass
    end

    def name
      klass = self.class == Class ? self : self.class
      klass.to_s
    end

    def self.subclasses
      @subclasses
    end

    def self.satisfies_event_list?(events)
      klass = self.class == Class ? self : self.class
      klass.event_list && !klass.responds_to_events?(events) && !klass.event_list.empty?
    end

    def conditions_met?(events, actor, subject, extras = {})
      return false if self.class.event_list.blank? && self.class.rule_triggers.blank?

      if self.class.satisfies_event_list?(events)
        return false
      end

      self.class.conditions_methods.each do |method|
        return false unless self.send(method, events, actor, subject, extras)
      end

      triggers_called = []
      self.class.rule_triggers.each do |trigger_hash|
        rule_trigger = trigger_hash[:trigger]
        parameters = trigger_hash[:parameters]
        trigger = rule_trigger.new(parameters, actor, subject, extras)
        trigger.logger = logger.logger(rule_trigger.to_s) if logger
        if !trigger.class.responds_to_events?(events + [:none]) || !trigger.conditions_met?
          return false
        end
        triggers_called << trigger
      end if self.class.rule_triggers


      triggers_called.each { |trigger| trigger.after_trigger }

      true
    end

    def self.trigger_test(events)

      return false if self.event_list.blank? && self.rule_triggers.blank?

      if self.satisfies_event_list?(events)
        return false
      end

      self.rule_triggers.each do |trigger_hash|
        rule_trigger = trigger_hash[:trigger]
        if !rule_trigger.responds_to_events?(events + [:none])
          return false
        end
      end if self.rule_triggers

      true
    end

    #do some stuff
    def perform(actor, subject, extras = {})
    end

    def enabled?
      true
    end

    def execute(events, actor, subject, extras = {})
      if self.conditions_met?(events, actor, subject, extras)
        begin
          extras[:events] = events
          log "Conditions met rule #{self.name} will now execute its actions ..."
          self.perform(actor, subject, extras)
        rescue Exception=>e
          log_error(e, events, actor, subject, extras)
          Airbrake.notify(e) if Rails.env=='production'
          raise e if (e.kind_of? EventException) || Rails.env=='test' || Rails.env=='development'
        end
      end
    end

    def self.parameters
      @parameters
    end

    def boost_point(points)
      boost = points
      multiplier = PointsBoost.active.first
      if multiplier
        Rails.logger.info "Point Booster exists. Multiplying points by #{multiplier.multiplier}."
        boost = boost * multiplier.multiplier
      end
      boost
    end

    protected

    def log(body_str)
      logger.log(body_str) if logger
    end

    def logger
      @logger
    end

    def do_action(symbol, actor, subject, options = {})
      action = "EventActions::#{symbol.to_s.camelize}".constantize.new(options, actor, subject)
      action.logger = logger.logger(action.class.to_s) if logger
      action.perform
    end

    def self.load_parameter(symbol, entity_type, type, options)
      parameter = BuiltInRuleParameter.where(entity_id: nil, entity_type: entity_type, name: symbol.to_s).first
      if (options[:required] || options[:required] == :true)
        raise RequiredParameterException.new(symbol) unless parameter
      end
      result = if parameter
                 parameter.value
               else
                 nil
                 options[:default] if options[:default] && parameter.nil?
               end
      case type
        when :integer then
          result.to_i
        when :boolean then
          result=='true'
        else
          result
      end
    end

    def self.has_parameter(symbol, type, options ={})
      @parameters||= []
      @parameters << {name: symbol, type: type, options: options}
      entity_type = self::ENTITY_TYPE
      define_singleton_method(symbol) do
        Proc.new {
          self.load_parameter(symbol, entity_type, type, options)
        }
      end
      value_accessor_method_name = "#{symbol.to_s}_value".to_sym
      define_singleton_method(value_accessor_method_name) do
        self.send(symbol).call
      end

      define_method(symbol) do
        value = self.instance_variable_get("@#{symbol.to_s}")
        if value.nil?
          value = self.class.send(symbol).call
          self.instance_variable_set("@#{symbol.to_s}", value)
        end
        value
      end
    end

    def log_error(exception, events, actor, subject, extras)
      Rails.logger.error("Error while executing rule #{self.name} with payload event: #{events.inspect} #{actor.inspect} #{subject.inspect} #{extras.inspect}")
      Rails.logger.error(exception.to_s)
    end

    #This method should return true if one or all of the events can trigger this Trigger
    def self.responds_to_events?(events)

      event_list.each { |event_group|
        events = [events] unless events.is_a? Array
        return true if (event_group - events).empty?
      }
      return false
    end

    def self.event_list
      @event
    end

    def self.listens_to(*events)
      @event ||= []
      @and_events = []
      events.each { |event|
        @and_events << event
      }
      @event << @and_events
    end

    def self.rule_triggers
      @triggers
    end

    def self.use_trigger(trigger, options = {})
      @triggers ||= []
      @triggers << {trigger: "EventTriggers::#{trigger.to_s.camelize}".constantize, parameters: options}
    end

    def self.conditions_methods
      @conditions_methods ||= []
      @conditions_methods
    end

    def self.conditions_method(*symbols)
      @conditions_methods ||= []
      @conditions_methods += symbols
    end

  end
end
