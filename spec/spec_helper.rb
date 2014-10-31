require "pure_form"
require "active_record"

module SpecNamespace
end

I18n.enforce_available_locales = false

ActiveRecord::Migration.verbose = false

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

Class.new(ActiveRecord::Migration) do
  def up
    create_table :dummies do |t|
      t.string :email
      t.integer :age
      t.date :birthday
      t.boolean :admin
      t.timestamps
    end
  end
end.new.up

Dummy = Class.new(ActiveRecord::Base)
