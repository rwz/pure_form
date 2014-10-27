module PureForm
  class Attribute
    attr_reader :context, :name, :options, :value_type

    def initialize(context, name, options)
      @context, @name, @options = context, name.to_s, options
      @value_type = build_value_type
    end

    def define
      define_setter
      define_complex_setter
      define_getter
      define_predicate
    end

    private

    def define_setter
      define_for_context "#{name}=", &setter_proc
    end

    def define_complex_setter
      return unless value_type.respond_to?(:complex_typecast)
      method_name = "set_complex_#{name}_value"
      define_for_context method_name, &complex_setter_proc
    end

    def define_getter
      define_for_context name, &getter_proc
    end

    def define_predicate
      define_for_context "#{name}?", &predicate_proc
    end

    def define_for_context(name, &block)
      context.instance_eval do
        define_method name, &block
      end

      nil
    end

    def setter_proc
      attribute_name = name
      type = value_type
      ->(value){ store_attribute(attribute_name, type.typecast(value)) }
    end

    def complex_setter_proc
      setter_name = "#{name}="
      type = value_type
      ->(*values){ public_send setter_name, type.complex_typecast(*values) }
    end

    def getter_proc
      attribute_name = name
      ->{ read_attribute(attribute_name) }
    end

    def predicate_proc
      attribute_name = name
      ->{ public_send(attribute_name).present? }
    end

    def build_value_type
      return Types::BaseType.new(options) unless options.key?(:type)
      type = options.delete(:type)
      "PureForm::Types::#{type.to_s.classify}Type".constantize.new(options)
    end
  end
end
