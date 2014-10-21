module PureForm
  class Base
    class << self
      def attribute(name, **options)
        Attribute.new(self, name, options).define
      end
    end

    def initialize(attributes=nil)
      assign_attributes attributes if attributes
    end

    def assign_attributes(attributes)
      Assignment.new(self, attributes).perform
    end
  end
end
