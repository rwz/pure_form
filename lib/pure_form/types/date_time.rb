module PureForm
  module Types
    class DateTimeType < BaseType
      def typecast(value)
        value.to_datetime
      rescue TypeError, ArgumentError, NoMethodError
        nil
      end

      def complex_typecast(*args)
        DateTime.new(*args)
      rescue TypeError, ArgumentError, NoMethodError
        nil
      end
    end
  end
end
