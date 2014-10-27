module PureForm
  module Types
    class FloatType < BaseType
      def typecast(value)
        value.to_f
      rescue NoMethodError
        nil
      end
    end
  end
end
