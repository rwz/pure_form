require "spec_helper"

describe PureForm::Base do
  def build_class(&block)
    Class.new(described_class, &block)
  end

  subject(:instance){ klass.new }

  context "attributes" do
    context "defining" do
      let(:klass){ build_class }

      context "base" do
        it "defines base attribute by default" do
          klass.attribute :first_name
          expect(klass.attributes[:first_name].value_type).to be_instance_of(PureForm::Types::BaseType)
        end
      end

      context "string" do
        it "defines string attribute using symbol" do
          klass.attribute :first_name, type: :string
        end

        it "defines string attribute using class" do
          klass.attribute :first_name, type: String
        end

        after do
          expect(klass.attributes[:first_name].value_type).to be_instance_of(PureForm::Types::StringType)
        end
      end

      context "integer" do
        it "defines integer attribute using symbol" do
          klass.attribute :age, type: :integer
        end

        it "defines integer attribute using class" do
          klass.attribute :age, type: Integer
        end

        after do
          expect(klass.attributes[:age].value_type).to be_instance_of(PureForm::Types::IntegerType)
        end
      end

      context "float" do
        it "defines float attribute using symbol" do
          klass.attribute :height, type: :float
        end

        it "defines float attribute using class" do
          klass.attribute :height, type: Float
        end

        after do
          expect(klass.attributes[:height].value_type).to be_instance_of(PureForm::Types::FloatType)
        end
      end

      context "boolean" do
        it "defines boolean attribute using symbol" do
          klass.attribute :admin, type: :boolean
        end

        it "defines boolean attribute using class" do
          klass.attribute :admin, type: described_class::Boolean
        end

        after do
          expect(klass.attributes[:admin].value_type).to be_instance_of(PureForm::Types::BooleanType)
        end
      end

      context "date" do
        it "defines date attributes using symbol" do
          klass.attribute :birthday, type: :date
        end

        it "defines date attribute using class" do
          klass.attribute :birthday, type: Date
        end

        after do
          expect(klass.attributes[:birthday].value_type).to be_instance_of(PureForm::Types::DateType)
        end
      end

      context "datetime" do
        it "defines datetime attribute using symbol" do
          klass.attribute :updated_at, type: :datetime
        end

        it "defines datetime attribute using class" do
          klass.attribute :updated_at, type: DateTime
        end

        after do
          expect(klass.attributes[:updated_at].value_type).to be_instance_of(PureForm::Types::DateTimeType)
        end
      end
    end

    context "reading" do
      let :klass do
        build_class do
          attribute :first_name, type: String
          attribute :last_name, type: String
          attribute :age, type: Integer
        end
      end

      it "contains all available attributes" do
        expect(instance.attributes).to include(:first_name)
        expect(instance.attributes).to include(:last_name)
        expect(instance.attributes).to include(:age)
      end

      it "does not contain attributes from subclasses" do
        subklass = Class.new(klass) do
          attribute :admin, type: :boolean
        end

        expect(subklass.new.attributes).to include(:admin)
        expect(instance.attributes).to_not include(:admin)
      end

      it "returns hash with indifferent access" do
        instance.first_name = "Pavel"
        expect(instance.attributes[:first_name]).to eq("Pavel")
        expect(instance.attributes["first_name"]).to eq("Pavel")
      end
    end

    context "assigning" do
      let :klass do
        build_class do
          attribute :name
          attribute :age
          attribute :admin
          attribute :height
          attribute :balance
          attribute :birthday, type: :date
          attribute :updated_at, type: :datetime
        end
      end

      context "plain" do
        it "assigns attributes using assing_attributes method" do
          instance.assign_attributes(
            name:   "Pavel",
            age:    28,
            admin:  true,
            height: 179
          )
        end

        it "assigns attributes using attributes= method" do
          instance.attributes = {
            name:   "Pavel",
            age:    28,
            admin:  true,
            height: 179
          }
        end

        it "only assignes defined attributes using assign_defined_attributes method" do
          instance.assign_defined_attributes(
            name:   "Pavel",
            age:    28,
            admin:  true,
            height: 179,
            foo:    "foo",
            bar:    Object.new,
            baz:    false
          )
        end

        after do
          expect(instance.name).to eq("Pavel")
          expect(instance.age).to eq(28)
          expect(instance.admin).to eq(true)
          expect(instance.height).to eq(179)
          expect(instance.balance).to be_nil
        end
      end

      context "complex" do
        it "assigns complex attributes" do
          instance.assign_attributes(
            "birthday(1i)" => "1986",
            "birthday(2i)" => "08",
            "birthday(3i)" => "25",
            "updated_at(1i)" => "2014",
            "updated_at(2i)" => "10",
            "updated_at(3i)" => "31",
            "updated_at(4i)" => "12",
            "updated_at(5i)" => "13",
            "updated_at(6i)" => "14"
          )

          expect(instance.birthday).to eq(Date.new(1986, 8, 25))
          expect(instance.updated_at).to eq(DateTime.new(2014, 10, 31, 12, 13, 14))
        end

        it "assigns complex attribute to nil when values are missing" do
          instance.assign_attributes(
            "birthday(1i)" => "1986",
            "birthday(3i)" => "25",
            "updated_at(4i)" => "10"
          )

          expect(instance.birthday).to be_nil
          expect(instance.updated_at).to be_nil
        end

        it "sets complex attribute to nil when values are invalid" do
          instance.assign_attributes(
            "birthday(1i)" => "1986",
            "birthday(2i)" => "800",
            "birthday(3i)" => "2500",
            "updated_at(1i)" => "2014",
            "updated_at(2i)" => "10",
            "updated_at(3i)" => "31",
            "updated_at(4i)" => "12",
            "updated_at(5i)" => "130",
            "updated_at(6i)" => "14"
          )

          expect(instance.birthday).to be_nil
          expect(instance.updated_at).to be_nil
        end
      end
    end

    context "errors" do
      it "raises UnknownAttributeError when trying to assing non-existent attribute" do
        action = ->{ build_class.new.assign_attributes foo: "bar" }
        expect(&action).to raise_error(PureForm::Errors::UnknownAttributeError)
      end

      it "raises MissingComplexAttributeError when trying to assign non-existent complex attrbute" do
        action = ->{ build_class.new.assign_attributes "missing(3i)" => 1986 }
        expect(&action).to raise_error(PureForm::Errors::MissingComplexAttributeError)
      end
    end
  end

  context "setter/getter" do
    let :klass do
      attribute_type = type

      build_class do
        attribute :something, type: attribute_type
      end
    end

    context "string" do
      let(:type){ :string }

      it "converts values to string" do
        instance.something = 123
        expect(instance.something).to eq("123")
        instance.something = true
        expect(instance.something).to eq("true")
      end
    end

    context "integer" do
      let(:type){ :integer }

      it "converts values to integer" do
        instance.something = "123"
        expect(instance.something).to eq(123)
        instance.something = 123.4
        expect(instance.something).to eq(123)
        instance.something = "foo"
        expect(instance.something).to eq(0)
        instance.something = ""
        expect(instance.something).to be_nil
        instance.something = Object.new
        expect(instance.something).to be_nil
      end
    end

    context "float" do
      let(:type){ :float }

      it "converts values to float" do
        instance.something = 123
        expect(instance.something).to eq(123.0)
        instance.something = "123.4"
        expect(instance.something).to eq(123.4)
        instance.something = "foo"
        expect(instance.something).to eq(0.0)
        instance.something = ""
        expect(instance.something).to be_nil
        instance.something = Object.new
        expect(instance.something).to be_nil
      end
    end

    context "boolean" do
      let(:type){ :boolean }

      it "converts values to boolean" do
        instance.something = true
        expect(instance.something).to eq(true)
        instance.something = 1
        expect(instance.something).to eq(true)
        instance.something = "1"
        expect(instance.something).to eq(true)
        instance.something = "t"
        expect(instance.something).to eq(true)
        instance.something = "T"
        expect(instance.something).to eq(true)
        instance.something = "true"
        expect(instance.something).to eq(true)
        instance.something = "TRUE"
        expect(instance.something).to eq(true)
        instance.something = "on"
        expect(instance.something).to eq(true)
        instance.something = "ON"
        expect(instance.something).to eq(true)
        instance.something = "on"
        expect(instance.something).to eq(true)
        instance.something = false
        expect(instance.something).to eq(false)
        instance.something = 0
        expect(instance.something).to eq(false)
        instance.something = "0"
        expect(instance.something).to eq(false)
        instance.something = :foo
        expect(instance.something).to eq(false)
        instance.something = 10
        expect(instance.something).to eq(false)
        instance.something = "foo"
        expect(instance.something).to eq(false)
      end
    end

    context "date" do
      let(:type){ :date }

      it "converts values to date" do
        birthday = Date.new(1986, 8, 25)
        instance.something = "1986-08-25"
        expect(instance.something).to eq(birthday)
        instance.something = "1986-8-25"
        expect(instance.something).to eq(birthday)
        instance.something = "1986/08/25"
        expect(instance.something).to eq(birthday)
        instance.something = "25 Aug 1986"
        expect(instance.something).to eq(birthday)
        instance.something = "Mon, 25 Aug 1986"
        expect(instance.something).to eq(birthday)
        instance.something = :foo
        expect(instance.something).to be_nil
      end
    end
  end

  context "predicate" do
    let :klass do
      build_class do
        attribute :something
      end
    end

    it "is true if value is present" do
      instance.something = true
      expect(instance).to be_something
      instance.something = Object.new
      expect(instance).to be_something
    end

    it "is false if value is not present" do
      expect(instance).to_not be_something
      instance.something = false
      expect(instance).to_not be_something
      instance.something = nil
      expect(instance).to_not be_something
      instance.something = []
      expect(instance).to_not be_something
    end
  end

  context "initializing" do
    it "assigns passed attributes" do
      klass = build_class do
        attribute :first_name
        attribute :last_name
      end

      instance = klass.new(first_name: "Pavel", last_name: "Pravosud")

      expect(instance.first_name).to eq("Pavel")
      expect(instance.last_name).to eq("Pravosud")
    end

    it "assigns default values" do
      klass = build_class do
        attribute :first_name, default: "Pavel"
        attribute :last_name, default: "Pravosud"
      end

      instance = klass.new

      expect(instance.first_name).to eq("Pavel")
      expect(instance.last_name).to eq("Pravosud")
    end
  end

  context "form name" do
    def form_name(klass)
      klass.model_name.param_key
    end

    it "has default form name based on class name" do
      SpecNamespace::RegistrationForm = build_class
      expect(form_name(SpecNamespace::RegistrationForm)).to eq("registration")
    end

    it "can redefine form name" do
      SpecNamespace::RegistrationForm2 = build_class do
        form_name :sign_up
      end

      expect(form_name(SpecNamespace::RegistrationForm2)).to eq("sign_up")
    end

    it "doesn't inherit dynamic form name" do
      SpecNamespace::ParentForm = build_class
      SpecNamespace::ChildForm = Class.new(SpecNamespace::ParentForm)

      expect(form_name(SpecNamespace::ParentForm)).to eq("parent")
      expect(form_name(SpecNamespace::ChildForm)).to eq("child")
    end

    it "does inherit custom form name" do
      SpecNamespace::ParentForm2 = build_class{ form_name :awesome }
      SpecNamespace::ChildForm2 = Class.new(SpecNamespace::ParentForm2)

      expect(form_name(SpecNamespace::ChildForm2)).to eq("awesome")
    end
  end

  context "validation and updates" do
    let :klass do
      build_class do
        attribute :name
        attribute :age

        validates :name, presence: true
        validates :age, numericality: true
      end
    end

    it "supports AM::M validations" do
      expect(instance).to be_invalid
      expect(instance.errors).to include(:name)
      expect(instance.errors).to include(:age)
      instance.assign_attributes name: "Pavel", age: 28
      expect(instance).to be_valid
      expect(instance.errors).to be_empty
    end

    it "returns true on update when validations pass" do
      expect(instance.update(name: "Pavel", age: 28)).to eq(true)
    end

    it "returns false on update when validations fail" do
      expect(instance.update(name: nil, age: "foo")).to eq(false)
    end
  end

  context "copy attributes from AR::Base" do
    it "raises an error when trying to copy attributes from non AR::Base class" do
      action = ->{ build_class.copy_attributes_from Object }
      expect(&action).to raise_error(ArgumentError)
    end

    context "with no options" do
      let :klass do
        build_class do
          copy_attributes_from ::Dummy
        end
      end

      it "copies string attribute from AR model" do
        expect(klass.attributes[:email].value_type).to be_instance_of(PureForm::Types::StringType)
      end

      it "copies integer attribute from AR model" do
        expect(klass.attributes[:age].value_type).to be_instance_of(PureForm::Types::IntegerType)
      end

      it "copies date attribute from AR model" do
        expect(klass.attributes[:birthday].value_type).to be_instance_of(PureForm::Types::DateType)
      end

      it "copies boolean attribute from AR model" do
        expect(klass.attributes[:admin].value_type).to be_instance_of(PureForm::Types::BooleanType)
      end

      it "copies datetime attributes from AR model" do
        expect(klass.attributes[:updated_at].value_type).to be_instance_of(PureForm::Types::DateTimeType)
        expect(klass.attributes[:created_at].value_type).to be_instance_of(PureForm::Types::DateTimeType)
      end
    end

    context "only/except" do
      let(:klass){ build_class }

      it "supports only option for a single attribute" do
        klass.copy_attributes_from Dummy, only: :age
        expect(klass.attributes).to include(:age)
        expect(klass.attributes).not_to include(:email, :birthday, :admin, :updated_at, :created_at)
      end

      it "supports only option for an array of attributes" do
        klass.copy_attributes_from Dummy, only: %i[updated_at created_at]
        expect(klass.attributes).to include(:updated_at, :created_at)
        expect(klass.attributes).not_to include(:email, :age, :birthday, :admin)
      end

      it "supports except option for a single attribute" do
        klass.copy_attributes_from Dummy, except: :age
        expect(klass.attributes).to include(:email, :birthday, :admin, :updated_at, :created_at)
        expect(klass.attributes).to_not include(:age)
      end

      it "supports except option for an array of attributes" do
        klass.copy_attributes_from Dummy, except: %i[updated_at created_at]
        expect(klass.attributes).to include(:email, :age, :birthday, :admin)
        expect(klass.attributes).not_to include(:updated_at, :created_at)
      end
    end
  end
end
