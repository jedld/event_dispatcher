class CreateEdTables < ActiveRecord::Migration

  def self.up
    create_table "ed_rule_actions", :force => true do |t|
      t.integer "rule_id"
      t.integer "action_type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "ed_rule_parameters", :force => true do |t|
      t.integer "rule_id"
      t.integer "entity_id"
      t.integer "entity_type"
      t.string "name", :limit => 50
      t.string "description", :limit => 150
      t.string "value", :limit => 150
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "ed_rule_parameters", ["name"], :name => "index_rule_parameters_on_name"
    add_index "ed_rule_parameters", ["rule_id", "name"], :name => "index_rule_parameters_on_rule_id_and_name"

    create_table "ed_rule_triggers", :force => true do |t|
      t.integer "rule_id"
      t.integer "trigger_type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "ed_rules", :force => true do |t|
      t.string "name"
      t.string "description"
      t.boolean "enabled", :default => true
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
    drop_table :ed_rules
    drop_table :ed_rule_triggers
    drop_table :ed_rule_parameters
    drop_table :ed_rule_actions
  end
end
