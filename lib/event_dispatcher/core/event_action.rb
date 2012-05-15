module EventDispatcher::Core
  class EventAction

    extend EventDispatcher::Core::RuleObjectHelper

    attr_accessor :actor, :subject, :rule_data, :parameters, :logger

    def initialize(parameters, actor, subject, rule_data = {})
      self.actor = actor
      self.subject = subject
      self.rule_data = rule_data
      self.parameters = parameters
    end

    def self.get_action_from_id(event_action_id)
      EventDispatcher::Engine.force_load_classes
      self.subclasses.each { |klass|
        return klass if klass::ENTITY_TYPE == event_action_id
      }
    end

    def perform
    end

    def self.get_name
      @name
    end

    def self.get_description
      @description
    end

    def validate

    end

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


    protected

    def log(body)
      logger.log body if logger
    end

    def self.action_name(name)
      @name = name
    end

    def self.description(description)
      @description = description
    end

  end
end