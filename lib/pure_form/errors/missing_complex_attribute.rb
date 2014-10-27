module PureForm
  module Errors
    class MissingComplexAttributeError < StandardError
      def self.build(key)
        new(":#{key} attribute doesn't have a complex setter")
      end
    end
  end
end
