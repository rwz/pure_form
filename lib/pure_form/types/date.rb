module PureForm
  module Types
    class DateType < BaseType
      def typecast(value)
        value.to_date
      rescue TypeError, ArgumentError, NoMethodError
        nil
      end

      def complex_typecast(year, month, day)
        Date.new(year, month, day)
      rescue TypeError, ArgumentError
        nil
      end
    end
  end
end
