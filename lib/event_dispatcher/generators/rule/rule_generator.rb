class RuleGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  argument :events, :type => :string, :default=>nil, :required=>false

  def copy_rule_file
    @class_name = "#{name}_rule".camelize
    @next_type = EventDispatcher::Core::Engine.get_next_entity_type(EventDispatcher::Core::EventRuleBase)
    @listens_to = []

    unless events.nil?
      @listens_to = events.split(',')
      @listens_to_str = @listens_to.map{ |e| ":#{e}"}.join(', ')
    end
    
    template File.expand_path('../templates', __FILE__) + "/rule_template.rb.erb", "app/models/event_rules/#{name}_rule.rb"
    if defined?(RSpec)
      template File.expand_path('../templates', __FILE__) + "/rule_template_spec.rb.erb", "spec/models/event_rules/#{name}_rule_spec.rb"
    end
  end

end
