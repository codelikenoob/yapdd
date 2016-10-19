	class CreateEmails < ActiveRecord::Migration[5.0]
  def change
    create_table :emails do |t|
      t.integer :domain_id
      t.string :mailname
      t.date :birth_date
      t.string :iname
      t.string :fname
      t.string :hintq
      t.decimal :sex
      t.boolean :enabled
      t.boolean :signed_eula
      t.string :fio
      t.string :aliases
      t.string :pswrd
      t.string :hinta
      t.timestamps null: false
    end
  end
end
