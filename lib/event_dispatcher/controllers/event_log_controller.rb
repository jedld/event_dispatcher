class EventDispatcher::EventLogController < ActionController::Base

  layout false

  def console
    logger = logger_for_session

    other_logger = EventDispatcher::Core::MemcacheEventLog.new("unknown")

    @active_rules = []
    EventDispatcher::Core::Engine.dispatch_backend.get_built_in_rules.each do |k, rule|
      if rule.enabled?
        param_list = []
        @active_rules << {name: rule.name, klass: rule, params: param_list}
        rule.class.parameters.each do |params|
          param_list << {name: params[:name], value: rule.send(params[:name])}
        end if rule.class.parameters
      end
    end

    @event_logs = logger.to_a
    @other_event_logs = other_logger.to_a
  end

  def clear
    logger = logger_for_session
    logger.clear
    redirect_to event_console_path
  end

  private

  def logger_for_session
    EventDispatcher::Core::MemcacheEventLog.new(get_logger_session_id)
  end

end
