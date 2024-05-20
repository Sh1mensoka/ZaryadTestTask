# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[7.0]
  def up
    change_table :users do |t|
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
  end

  def down
    change_table :users do |t|
      t.remove :email
      t.remove :encrypted_password

      t.remove :reset_password_token
      t.remove :reset_password_sent_at
    end

    remove_index :users, :email,                if_exists: true
    remove_index :users, :reset_password_token, if_exists: true
  end
end
