class ChangeQueryToListing < ActiveRecord::Migration[6.0]
  def change
    rename_table :queries, :listings
  end
end
