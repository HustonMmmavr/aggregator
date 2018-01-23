class AddAppSecretToApplicationKeys < ActiveRecord::Migration[5.1]
  def change
    add_column :application_keys, :appSecret, :string
  end
end
