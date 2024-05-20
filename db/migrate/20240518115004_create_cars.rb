# frozen_string_literal: true

class CreateCars < ActiveRecord::Migration[7.0]
  def up
    create_table :cars do |t|
      t.string :model,          null: false
      t.string :license_number, null: false
      t.string :status,         null: false, default: 'available'

      t.timestamps
    end
  end

  def down
    drop_table :cars
  end
end
