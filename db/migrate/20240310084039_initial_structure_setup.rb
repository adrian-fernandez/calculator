# frozen_string_literal: true

class InitialStructureSetup < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_table :surnames do |t|
      t.string :surname, null: false
      t.string :nationalities

      t.timestamps
    end

    add_index :surnames, :surname, unique: true
  end
end
