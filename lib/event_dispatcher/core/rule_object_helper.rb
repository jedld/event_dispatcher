module EventDispatcher::Core
  module RuleObjectHelper

    def get_kind_of_actor
      @actor_type
    end

    def get_kind_of_subject
      @subject_type
    end

    protected

    def has_parameter(symbol, type, options ={})
      define_method(symbol) do
        parameter = parameters[symbol]
        if (options[:required] || options[:required] == :true)
          raise RequiredParameterException.new(symbol) unless parameter
        end
        result = if parameter
          parameter
        else
          nil
          options[:default] if options[:default] && parameter.nil?
        end
        result = result.class == Proc ? result.call : result
        case type
          when :integer then
            result.to_i
          when :boolean then
            result!='false' && result!=:false
          else
            result
        end
      end
    end

    def requires_kind_of_actor(klass)
      if (klass == :custom)
        @actor_type = :custom
      else
        klass = klass.to_s.camelize.constantize if klass.is_a? Symbol
        @actor_type = klass
      end
    end

    def requires_kind_of_subject(klass)
      if (klass == :custom)
        @subject_type = :custom
      else
        klass = klass.to_s.camelize.constantize if klass.is_a? Symbol
        @subject_type = klass
      end
    end
  end
end