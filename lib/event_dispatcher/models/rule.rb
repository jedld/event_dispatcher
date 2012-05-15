class EventDispatcher::Core::Rule < ActiveRecord::Base

  has_many :rule_triggers, :class_name => "EventDispatcher::Core::RuleTrigger", :inverse_of => :rule
  has_many :rule_actions, :class_name => "EventDispatcher::Core::RuleAction", :inverse_of => :rule
  has_many :rule_parameters, :class_name => "EventDispatcher::Core::RuleParameter", :as=>:entity

  validate :trigger_data_types_valid?
  validates :description,  :length => { :maximum => 255 }
  validates :name,  :length => { :maximum => 255 }

  
  def conditions_met?(events, actor, subject, extras = {})
    rule_trigger_list = []
    self.rule_triggers.each do |rule_trigger|
      trigger = rule_trigger.conditions_met?(events, actor, subject, extras)
      return false unless trigger
      rule_trigger_list << trigger
    end

    rule_trigger_list.each { |t|
      t.after_trigger
    }
    true
  end

  def perform(actor, subject, extras = {})
    self.rule_actions.each do |rule_action|
      rule_action.perform(actor, subject, extras)
    end
  end

  def execute(events, actor, subject, extras = {})
    if self.conditions_met?(events, actor, subject, extras)
        begin
          self.perform(actor, subject, extras)
        rescue Exception=>e
          log_error(e, events, actor, subject, extras )
          raise e if (e.kind_of? EventDispatcher::Core::EventException) || Rails.env=='test'
        end
      end
  end

  def log_error(exception, events, actor, subject, extras )
      Rails.logger.error("Error while executing rule #{self.class.to_s} with payload event: #{events.inspect} #{actor.inspect} #{subject.inspect} #{extras.inspect}")
      Rails.logger.error(exception.to_s)
  end

  def trigger_data_types_valid?
    actors = []
    subjects = []
    custom_actors = []
    custom_subjects = []

    triggers.each do |klass|

      if klass.get_kind_of_actor
        if (klass.get_kind_of_actor == :custom)
          custom_actors << klass
        else
          actors << klass.get_kind_of_actor
        end
      end

      if klass.get_kind_of_subject
        if (klass.get_kind_of_subject == :custom)
          custom_subjects << klass
        else
          subjects << klass.get_kind_of_subject
        end
      end
    end

    unless (actors.uniq.size<=1 && subjects.uniq.size<=1)
      errors.add(:rule_triggers, "invalid combination of triggers, they all should require the same types of actor and subjects")
    end

    actor_class = actors.uniq.first
    subject_class = subjects.uniq.first

    custom_actors.each do |klass|
     klass.validates_kind_of_actor(actor_class, errors)
    end

    custom_subjects.each do |klass|
     klass.validates_kind_of_actor(subject_class, errors)
    end

  end

  def triggers
    rule_triggers.collect { |rt|
      rt.get_trigger
    }
  end

end
