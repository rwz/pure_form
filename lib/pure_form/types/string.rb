module PureForm
  module Types
    class StringType < BaseType
      def typecast(value)
        value.to_s
      end
    end
  end
end
