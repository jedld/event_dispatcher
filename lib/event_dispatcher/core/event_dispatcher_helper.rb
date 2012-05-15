module EventDispatcher::Core::EventDispatcherHelper

  protected

  def fire_event(event, actor = nil, subject = nil, options = {})
    session_id = get_logger_session_id
    options[:session_id] = session_id if session_id
    EventDispatcher::Engine.fire(event, actor, subject, options)
  end

  def event_logger
    session_id = get_logger_session_id
    EventDispatcher::Engine.dispatch_backend.config.logger_backend.new(session_id) if session_id &&  EventDispatcher::Engine.dispatch_backend.config
  end

  private

  def get_logger_session_id
    if self.respond_to?(:current_user)
      current_user.id if current_user
    elsif self.respond_to?(:user)
      user.id if user
    elsif self.respond_to?(:avatar)
      avatar.user.id if avatar.user
    end
  end

end