class CreateRuleTriggers < ActiveRecord::Migration
  def self.up
    create_table :rule_triggers do |t|
      t.integer :rule_id
      t.integer :trigger_type
      t.timestamps
    end
  end

  def self.down
    drop_table :rule_triggers
  end
end
