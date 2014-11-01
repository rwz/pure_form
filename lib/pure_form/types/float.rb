module PureForm
  module Types
    class FloatType < BaseType
      def typecast(value)
        value.blank?? nil : value.to_f
      rescue NoMethodError
        nil
      end
    end
  end
end
