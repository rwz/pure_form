module PureForm
  module Errors
    class UnknownAttributeError < NoMethodError
      def self.build(key)
        new("No such attribute: #{key.inspect}")
      end
    end
  end
end
