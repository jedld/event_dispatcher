class ActionGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  argument :parameters, :type => :string, :default=>nil, :required=>false
  class_option :action_name, :type => :string, :default =>"Name of action here", :description => "Specify the name of the action"
  class_option :description, :type => :string, :default =>"Place what your action does here", :description => "Specify a description for the action"

  def copy_rule_file
    @class_name = "#{name}_action".camelize
    @next_type = EventDispatcher::Core::Engine.get_next_entity_type(EventDispatcher::Core::EventAction)
    @action_name = options.action_name
    @action_description = options.description
    @parameters_array = []
    unless parameters.nil?
       @parameters_array = parameters.split(',')
    end

    template File.expand_path('../templates', __FILE__) + "/template_action.rb.erb", "app/models/event_actions/#{name}_action.rb"
    if defined?(RSpec)
      template File.expand_path('../templates', __FILE__) + "/template_action_spec.rb.erb", "spec/models/event_actions/#{name}_action_spec.rb"
    end
  end
end
