module PureForm
  module Types
    class BooleanType < BaseType
      TRUE_VALUES = [true, 1, "1", "t", "T", "true", "TRUE", "on", "ON"].to_set

      def typecast(value)
        TRUE_VALUES.include?(value)
      end
    end
  end
end
