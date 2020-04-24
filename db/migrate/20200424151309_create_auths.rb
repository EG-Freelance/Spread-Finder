class CreateAuths < ActiveRecord::Migration[6.0]
  def change
    create_table :auths do |t|
      t.text :auth_token
      t.text :refresh_token
      t.datetime :auth_token_exp
      t.datetime :refresh_token_exp

      t.timestamps
    end
  end
end
