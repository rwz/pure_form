module PureForm
  module Types
    class IntegerType < BaseType
      def typecast(value)
        value.blank?? nil : value.to_i
      rescue NoMethodError
        nil
      end
    end
  end
end
