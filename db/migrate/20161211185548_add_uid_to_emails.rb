class AddUidToEmails < ActiveRecord::Migration[5.0]
  def change
    add_column :emails, :uid, :integer
    add_index :emails, :uid, unique: true
  end
end
