class ChangeUidType < ActiveRecord::Migration[5.0]
  def change
    remove_column :emails, :uid
    add_column :emails, :uid, :string
    add_index :emails, :uid, unique: true
  end
end
