class CreateRuleParameters < ActiveRecord::Migration

  def self.up
    create_table :rule_parameters do |t|
      t.integer :rule_id
      t.integer :entity_id
      t.integer :entity_type
      t.string :name
      t.string :description
      t.string :value
      t.timestamps
    end

    add_index :rule_parameters, :name
    add_index :rule_parameters, [:rule_id, :name]
  end

  def self.down
    drop_table :rule_parameters
  end
end
