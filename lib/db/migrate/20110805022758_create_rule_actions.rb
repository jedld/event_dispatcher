class CreateRuleActions < ActiveRecord::Migration
  def self.up
    create_table :rule_actions do |t|
      t.integer :rule_id
      t.integer :action_type
      t.timestamps
    end
  end

  def self.down
    drop_table :rule_actions
  end
end
