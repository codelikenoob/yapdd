class CreateDomains < ActiveRecord::Migration[5.0]
  def change
    create_table :domains do |t|
      t.string :domainname
      t.string :domaintoken
      t.string :domaintoken2
      t.integer :user_id
      t.timestamps null: false
      t.string  :image
    end
  end
end
