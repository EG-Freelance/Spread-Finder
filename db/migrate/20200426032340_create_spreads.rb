class CreateSpreads < ActiveRecord::Migration[6.0]
  def change
    create_table :spreads do |t|
      t.string :sym
      t.string :year_week
      t.string :strike_5
      t.string :strike_4
      t.string :strike_3
      t.string :strike_2
      t.decimal :underlying_m
      t.decimal :five_three_val_m
      t.decimal :four_three_val_m
      t.decimal :three_two_val_m
      t.decimal :underlying_t
      t.decimal :five_three_val_t
      t.decimal :four_three_val_t
      t.decimal :three_two_val_t
      t.decimal :underlying_w
      t.decimal :five_three_val_w
      t.decimal :four_three_val_w
      t.decimal :three_two_val_w
      t.decimal :underlying_th
      t.decimal :five_three_val_th
      t.decimal :four_three_val_th
      t.decimal :three_two_val_th
      t.decimal :underlying_f
      t.decimal :five_three_val_f
      t.decimal :four_three_val_f
      t.decimal :three_two_val_f

      t.timestamps
    end
  end
end
