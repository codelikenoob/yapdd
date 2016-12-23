class AddMaillistToEmails < ActiveRecord::Migration[5.0]
  def change
    add_column :emails, :maillist, :boolean
  end
end
