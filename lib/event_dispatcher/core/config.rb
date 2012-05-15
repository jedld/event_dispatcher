module EventDispatcher::Core

  class Config
    attr_accessor :dispatch_backend, :logger_backend, :disable_all, :event_log

    def initialize
      self.disable_all = false
      self.event_log = false
      self.logger_backend = EventDispatcher::Core::MemcacheEventLog
      @enabled_rules = []
      @disabled_rules = []
    end

    def enabled=(rules = [])
      rules.each do |rule|
        @enabled_rules << rule.to_s.camelize.to_sym
      end
    end

    def disabled=(rules = [])
      rules.each do |rule|
        @disabled_rules << rule.to_s.camelize.to_sym
      end
    end

    def enabled
      @enabled_rules
    end

    def disabled
      @disabled_rules
    end

  end
end