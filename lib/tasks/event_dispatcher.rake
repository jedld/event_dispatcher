begin
  desc "Lists all parameters in each rule"
  namespace :event_dispatcher do
    task :list=>:environment do
      puts "Events:"
      EventDispatcher::Core::Engine.get_rules_by_events(EventDispatcher::Core::Engine.get_events_listened_to).each do |event_detail|
        puts "-------------------------------"
        puts "#{event_detail[:event]}:"
        event_detail[:rules].each do |rule|
          puts "     #{rule}"
        end
        puts " "
        puts " "
      end
    end

    desc "Generates the SQL to add the rule parameters to the DB"
    namespace :params do
      task :sql=>:environment do # checks for missing keys in all locale files
        insert_statements = []
        delete_statements = []
        force_load_classes
        EventDispatcher::Core::EventRuleBase.descendants.each do |klass|
          entity_type = klass::ENTITY_TYPE
          klass.parameters.each do |p|
            description = p[:options][:description] ? p[:options][:description] : "points for #{klass.to_s}"
            value = p[:options][:default] ? p[:options][:default] : nil
            values = {entity_type: entity_type, name: p[:name], value: value, description: description, created_at: Time.now.to_s}
            value_string = values.reject { |k,v| k==:entity_type}.values.map {|v| "'#{v}'"}.join(',')
            rp = BuiltInRuleParameter.where(entity_type: entity_type, entity_id: nil, rule_id: nil, name: p[:name]).first
            insert_statements << "INSERT INTO rule_parameters (entity_type, name, value, description, created_at) VALUES (#{entity_type},#{value_string});" unless rp
            delete_statements << "execute(\"DELETE FROM rule_parameters where entity_type = #{entity_type} AND name = '#{p[:name]}' AND entity_id IS NULL;\")"  unless rp
          end

        end
        insert_statements.each { |s| puts s}
        delete_statements.each { |s| puts s}
      end
    end
  end
end