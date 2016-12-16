class SexIsString < ActiveRecord::Migration[5.0]
  def change
    remove_column :emails, :sex
    add_column :emails, :sex, :string
  end
end
