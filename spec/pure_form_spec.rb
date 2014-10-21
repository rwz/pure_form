require "spec_helper"

describe PureForm do
  def build_class(&block)
    Class.new(described_class::Base, &block)
  end

  context "attributes" do
    subject(:instance){ klass.new }

    context "untyped attributes" do
      let :klass do
        build_class do
          attribute :name
        end
      end

      it "is nil by default" do
        expect(instance.name).to be_nil
      end

      it "does not perform any typecasting" do
        [ false, 123, Object.new, { foo: "bar" } ].each do |value|
          instance.name = value
          expect(instance.name).to eq(value)
        end
      end
    end

    context "string attributes" do
      let :klass do
        build_class do
          attribute :name, type: :string
        end
      end

      it "is nil by default" do
        expect(instance.name).to be_nil
      end

      it "performs typecast to String" do
        values = {
          "foo" => "foo",
          false => "false",
          123   => "123",
          [1,2] => "[1, 2]"
        }

        values.each do |value, str_value|
          instance.name = value
          expect(instance.name).to eq(str_value)
        end
      end
    end

    context "integer attribute" do
      let :klass do
        build_class do
          attribute :age, type: :integer
        end
      end

      it "is nil by default" do
        expect(instance.age).to be_nil
      end

      it "performs typecast to Integer" do
        values = {
          123   => 123,
          "123" => 123,
          "foo" => 0,
          false => nil,
          true  => nil,
          :foo  => nil
        }

        values.each do |value, int_value|
          instance.age = value
          expect(instance.age).to eq(int_value)
        end
      end
    end

    context "float attribute" do
      let :klass do
        build_class do
          attribute :height, type: :float
        end
      end

      it "is nil by default" do
        expect(instance.height).to be_nil
      end

      it "performs typecast to Float" do
        values = {
          123   => 123.0,
          "123" => 123.0,
          "foo" => 0.0,
          false => nil,
          true  => nil,
          :foo  => nil
        }

        values.each do |value, float_value|
          instance.height = value
          expect(instance.height).to eq(float_value)
        end
      end
    end

    context "boolean attribute" do
      let :klass do
        build_class do
          attribute :admin, type: :boolean
        end
      end

      it "is nil by default" do
        expect(instance.admin).to be_nil
      end

      it "performs typecast to Boolean" do
        values = {
          true   => true,
          1      => true,
          "1"    => true,
          "t"    => true,
          "T"    => true,
          "true" => true,
          "TRUE" => true,
          "on"   => true,
          "ON"   => true,
          false  => false,
          0      => false,
          "0"    => false,
          :foo   => false,
          10     => false,
          "foo"  => false
        }

        values.each do |value, boolean_value|
          instance.admin = value
          expect(instance.admin).to eq(boolean_value)
        end
      end
    end

    context "date attribute" do
      let :klass do
        build_class do
          attribute :birthday, type: :date
        end
      end

      it "is nil by default" do
        expect(instance.birthday).to be_nil
      end

      it "performs typecast to Date" do
        values = [
          "1986-08-25",
          "1986-8-25",
          "1986/08/25",
          "1986/8/25",
          "25 Aug 1986",
          "Mon, 25 Aug 1986"
        ]

        values.each do |value|
          instance.birthday = value
          expect(instance.birthday).to eq(Date.new(1986, 8, 25))
        end
      end
    end

    context "initialization" do
      let(:klass){ build_class }

      it "assigns attributes" do
        instance = klass.allocate
        attributes = {
          name:   "Pavel",
          age:    28,
          admin:  true,
          height: 179
        }

        expect(instance).to receive(:assign_attributes).with(attributes).once
        instance.send :initialize, attributes
      end
    end

    context "assign attributes" do
      let :klass do
        build_class do
          attribute :name
          attribute :age
          attribute :admin
          attribute :height
          attribute :balance
          attribute :birthday, type: :date
        end
      end

      it "assigns attributes" do
        instance.assign_attributes(
          name:   "Pavel",
          age:    28,
          admin:  true,
          height: 179
        )

        expect(instance.name).to eq("Pavel")
        expect(instance.age).to eq(28)
        expect(instance.admin).to eq(true)
        expect(instance.height).to eq(179)
        expect(instance.balance).to be_nil
      end

      it "assigns complex attributes" do
        instance.assign_attributes(
          "birthday(1i)" => "1986",
          "birthday(2i)" => "08",
          "birthday(3i)" => "25"
        )

        expect(instance.birthday).to eq(Date.new(1986, 8, 25))
      end

      it "sets complex attribute to nil if values are missing" do
        instance.assign_attributes(
          "birthday(1i)" => "1986",
          "birthday(3i)" => "25"
        )

        expect(instance.birthday).to be_nil
      end

      it "sets complex attribute to nil when values are invalid" do
        instance.assign_attributes(
          "birthday(1i)" => "1986",
          "birthday(2i)" => "800",
          "birthday(3i)" => "2500"
        )

        expect(instance.birthday).to be_nil
      end

      it "raises UnknownAttributeError when trying to assing non-existent attribute" do
        action = ->{ instance.assign_attributes foo: "bar" }
        expect(&action).to raise_error(PureForm::Errors::UnknownAttributeError)
      end

      it "rases MissingComplexAttributeError when trying to assign non-existent complex attrbute" do
        action = ->{ instance.assign_attributes "missing(3i)" => 1986 }
        expect(&action).to raise_error(PureForm::Errors::MissingComplexAttributeError)
      end
    end
  end
end
