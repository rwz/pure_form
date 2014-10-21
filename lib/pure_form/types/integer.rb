module PureForm
  module Types
    class IntegerType < BaseType
      def typecast(value)
        value.to_i
      rescue NoMethodError
        nil
      end
    end
  end
end
