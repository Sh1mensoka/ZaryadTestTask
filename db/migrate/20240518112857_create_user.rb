class CreateUser < ActiveRecord::Migration[7.0]
  def up
    create_table :users do |t|
      t.timestamps
    end
  end

  def down
    drop_table :users
  end
end
