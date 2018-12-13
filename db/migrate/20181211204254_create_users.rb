class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email
      t.string :username
      t.string :pf_pic
      t.string :first_name
      t.string :last_name
      t.string :password
      t.string :bio
      t.date :birthdate
    end
  end
end
