module PureForm
  class Attribute
    attr_reader :context, :name, :options

    def initialize(context, name, options)
      @context, @name, @options = context, name, options
      @value_type = build_value_type
    end

    def define
      define_setter
      define_complex_setter
      define_getter
    end

    private

    def define_setter
      define_for_context "#{name}=", &setter_proc
    end

    def define_complex_setter
      return unless @value_type.respond_to?(:complex_typecast)
      method_name = "set_complex_#{name}_value"
      define_for_context method_name, &complex_setter_proc
    end

    def define_getter
      define_for_context name, &getter_proc
    end

    def define_for_context(name, &block)
      context.instance_eval do
        define_method name, &block
      end
    end

    def setter_proc
      ivar = ivar_name
      type = @value_type
      ->(value){ instance_variable_set(ivar, type.typecast(value)) }
    end

    def complex_setter_proc
      setter_name = "#{name}="
      type = @value_type
      ->(*values){ public_send setter_name, type.complex_typecast(*values) }
    end

    def getter_proc
      ivar = ivar_name
      ->{ instance_variable_get(ivar) }
    end

    def ivar_name
      "@#{name}"
    end

    def build_value_type
      return Types::BaseType.new(options) unless options.key?(:type)
      type = options.delete(:type)
      "PureForm::Types::#{type.to_s.classify}Type".constantize.new(options)
    end
  end
end
