module PureForm
  class Assignment
    attr_reader :form, :attributes

    def initialize(form, attributes)
      @form, @attributes = form, attributes
    end

    def perform
      attributes.each do |key, value|
        if key =~ /\(\d+[if]\)\z/
          assign_complex_attribute key, value
        else
          assign_attribute key, value
        end
      end

      flush_complex_attributes
    end

    private

    def assign_attribute(attribute_name, value)
      setter = "#{attribute_name}="
      fail Errors::UnknownAttributeError.build(attribute_name) unless form.respond_to?(setter)
      form.public_send setter, value
    end

    def assign_complex_attribute(complex_attribute_name, value)
      attribute_name = complex_attribute_name[/\A[^(]+/]
      attribute_position = complex_attribute_name[/\((\d+)[if]\)\z/, 1].to_i - 1
      attribute_type = complex_attribute_name[/([if])\)\z/, 1]
      value = value.public_send("to_#{attribute_type}")
      complex_attributes[attribute_name][attribute_position] = value
    end

    def complex_attributes
      @complex_attributes ||= Hash.new{ |hash, key| hash[key] = [] }
    end

    def flush_complex_attributes
      complex_attributes.each do |key, values|
        method_name = "set_complex_#{key}_value"
        raise Errors::MissingComplexAttributeError.build(key) unless form.respond_to?(method_name)
        form.public_send method_name, *values
      end
    end
  end
end
