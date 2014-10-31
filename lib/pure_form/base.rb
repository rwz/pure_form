require "active_model"

module PureForm
  class Base
    include ActiveModel::Model

    class Boolean
      def self.to_s
        "Boolean"
      end
    end

    class_attribute :attributes, instance_accessor: false, instance_predicate: false

    class << self
      def attribute(name, **options)
        attribute = Attribute.new(self, name, options)
        self.attributes ||= HashWithIndifferentAccess.new
        self.attributes = attributes.merge(attribute.name => attribute)
        attribute.define
      end

      def model_name
        @model_name ||= build_model_name(to_s.remove(/^(\w+::)+/).remove(/Form$/))
      end

      def form_name(name)
        new_name = build_model_name(name)
        singleton_class.instance_eval do
          define_method(:model_name){ new_name }
        end
      end

      def copy_attributes_from(model, **options)
        raise ArgumentError unless model < ActiveRecord::Base

        included = Array.wrap(options.fetch(:only){ model.column_names }).map(&:to_s)
        excluded = Array.wrap(options[:except]).map(&:to_s)

        model.columns.each do |column|
          next if !column.name.in?(included) || column.name.in?(excluded)
          attribute column.name, type: column.type
        end
      end

      def default_values
        return {} unless attributes
        @default_values ||= attributes.each_with_object({}) do |(name, attribute), defaults|
          if attribute.options.key?(:default)
            defaults[name] = attribute.options.fetch(:default)
          end
        end
      end

      private

      def build_model_name(name)
        ActiveModel::Name.new(self, nil, name.to_s)
      end
    end

    def initialize(attributes=nil)
      assign_defaults
      assign_attributes attributes if attributes
    end

    def assign_attributes(attributes)
      Assignment.new(self, attributes).perform
    end

    alias_method :attributes=, :assign_attributes

    def attributes
      self.class.attributes.each_with_object({}) do |(name, _), attributes|
        attributes[name] = public_send(name)
      end.with_indifferent_access
    end

    def update(updates)
      assign_attributes updates
      valid?
    end

    private

    def assign_defaults
      defaults = self.class.default_values
      assign_attributes defaults unless defaults.empty?
    end

    def attributes_store
      @attributes_store ||= Hash.new
    end

    def store_attribute(name, value)
      attributes_store.store name, value
    end

    def read_attribute(name)
      attributes_store[name]
    end
  end
end
