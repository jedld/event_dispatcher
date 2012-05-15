class EventDispatcher::Models::RuleTrigger < ActiveRecord::Base

  set_table_name "ed_rule_triggers"

  belongs_to :rule, :inverse_of => :rule_triggers
  has_many :trigger_parameters, :as=>:entity
  validates_presence_of :rule

  def get_trigger
    EventDispatcher::Core::Trigger.get_trigger(trigger_type)
  end

  def conditions_met?(events, actor, subject, extras)
      trigger = get_trigger.new(load_rule_parameters, actor, subject, extras)
      if !trigger.class.responds_to_events?(events) || !trigger.conditions_met?
        return false
      end
      trigger
  end

  def trigger_type_enum
    EventDispatcher::Core::Engine.get_types(EventDispatcher::Core::Trigger)
  end

  def name
#    "#{rule.name}_#{Trigger.get_trigger(trigger_type).get_name}"
  end

  private

  def load_rule_parameters
    params = {}
    self.trigger_parameters.each { |p| params[p.name.to_sym] = p.value }
    params
  end
  
end
