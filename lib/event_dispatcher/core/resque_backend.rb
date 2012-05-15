module EventDispatcher::Core

  class ResqueBackend < EventDispatcher::Core::Backend

    def self.dispatch(events, actor, subject, extras)
      EventDispatcherWorker.submit_job(events, actor, subject, extras)
    end

  end

end