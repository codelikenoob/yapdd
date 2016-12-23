class AddFwdtoToEmails < ActiveRecord::Migration[5.0]
  def change
    add_column :emails, :fwdto, :string, array: true, default: []
  end
end
