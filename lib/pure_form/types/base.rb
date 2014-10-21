module PureForm
  module Types
    class BaseType
      def initialize(options={})
        @options = options
      end

      def typecast(value)
        value
      end
    end
  end
end
