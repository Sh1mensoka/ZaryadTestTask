# frozen_string_literal: true

class CreateRents < ActiveRecord::Migration[7.0]
  def up
    create_table :rents do |t|
      t.references :user, null: false
      t.references :car,  null: false

      t.string :status, null: false, default: 'started'

      t.timestamps
    end
  end

  def down
    drop_table :rents
  end
end
