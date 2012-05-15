class EventDispatcher::Core::RuleParameter < ActiveRecord::Base

  default_scope where('entity_id IS NOT NULL')
  belongs_to :entity, :polymorphic=>true

  validates :description,  :length => { :maximum => 150 }
  validates :name,  :length => { :maximum => 50 }
  validates :value,  :length => { :maximum => 150 }

end
