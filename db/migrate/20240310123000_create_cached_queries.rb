# frozen_string_literal: true

class CreateCachedQueries < ActiveRecord::Migration[7.1]
  def change
    create_table :cached_queries do |t|
      t.string :key
      t.string :value

      t.timestamps
    end

    add_index :cached_queries, :key
  end
end
