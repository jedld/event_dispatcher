class EventDispatcher::TriggerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  argument :events, :type => :string, :default=>nil, :required=>false
  class_option :trigger_name, :type => :string, :default =>"Name of action here", :description => "Specify the name of the action"
  class_option :description, :type => :string, :default =>"Place what your action does here", :description => "Specify a description for the action"

  def copy_trigger_file
    @class_name = "#{name}_trigger".camelize
    @next_type = EventDispatcher::Core::Engine.get_next_entity_type(EventDispatcher::Core::Trigger)
    @listens_to = []

    @trigger_name = options.trigger_name
    @trigger_description = options.description
    unless events.nil?
      @listens_to = events.split(',')
      @listens_to_str = @listens_to.map{ |e| ":#{e}"}.join(', ')
    end

    template File.expand_path('../templates', __FILE__) + "/trigger_template.rb.erb", "app/models/event_triggers/#{name}_trigger.rb"
    if defined?(RSpec)
      template File.expand_path('../templates', __FILE__) + "/trigger_template_spec.rb.erb", "spec/models/event_triggers/#{name}_trigger_spec.rb"
    end
  end
end
