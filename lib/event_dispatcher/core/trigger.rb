module EventDispatcher::Core
  class Trigger

    extend RuleObjectHelper

    attr_accessor :actor, :subject, :rule_data, :extras, :parameters, :logger

    def self.inherited(subclass)
      if superclass.respond_to? :inherited
        superclass.inherited(subclass)
      end
      @subclasses ||= []
      @subclasses << subclass
    end

    def self.subclasses
      @subclasses
    end

    def initialize(parameters, actor, subject, extras = {})
      self.actor = actor
      self.subject = subject
      self.extras = extras
      self.parameters = parameters
    end

    #This method should return true if one or all of the events can trigger this Trigger
    def self.responds_to_events?(events)
      events = [events] unless events.is_a? Array
      event_list.each { |event_group|
        return true if (event_group - events).empty?
      }
      return false
    end

    def self.responds_to
      event_list
    end

    #should return true if the necessary conditions for this trigger has been fullfilled
    def conditions_met?
      true
    end

    def self.get_name
      @name
    end

    def self.get_description
      @description
    end

    def self.get_trigger(trigger_type)
      EventDispatcher::Engine.force_load_classes
      subclasses.each { |klass|
        return klass if klass::ENTITY_TYPE==trigger_type
      }
    end


    #return true if all required parameters have been satisfied
    def validate
      return true
    end

    def after_trigger
    end

    protected

    def log(body_str)
      logger.log(body_str) if logger
    end

    def logger
      @logger
    end

    def self.listens_to(*events)
      and_events = []
      events.each { |event|
        and_events << event
      }
      event_list << and_events
    end

    def self.trigger_name(name)
      @name = name
    end

    def self.description(description)
      @description = description
    end

    private

    def self.event_list
      @event_list = [] unless @event_list
      @event_list
    end

  end
end