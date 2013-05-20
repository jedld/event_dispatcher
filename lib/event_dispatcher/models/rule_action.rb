class EventDispatcher::Models::RuleAction < ActiveRecord::Base

  self.table_name =  "ed_rule_actions"

  belongs_to :rule, :inverse_of => :rule_actions
  has_many :action_parameters, :as => :entity
  validates_presence_of :rule_id

  def perform(actor, subject, extras = {})
      event_action = EventDispatcher::Core::EventAction.get_action_from_id(self.action_type).new(load_rule_parameters, actor, subject, extras)

      event_action.perform()
  end

  def action_type_enum
    EventDispatcher::Core::Engine.get_types(EventDispatcher::Core::EventAction)
  end

  def name
    "#{rule.name}_#{EventDispatcher::Core::EventAction.get_action_from_id(self.action_type).get_name}"
  end
  
  private

  def load_rule_parameters
    params = {}
    self.action_parameters.each { |p| params[p.name.to_sym] = p.value }
    params
  end
  
end
