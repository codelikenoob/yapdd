class ChangeAliasesToArray < ActiveRecord::Migration[5.0]
  def change
    remove_column :emails, :aliases
    add_column :emails, :aliases, :string, array: true, default: []
  end
end
