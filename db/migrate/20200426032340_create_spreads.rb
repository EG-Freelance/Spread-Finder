class CreateSpreads < ActiveRecord::Migration[6.0]
  def change
    create_table :spreads do |t|
      t.string :sym
      t.string :year_week
      t.decimal :strike_5
      t.decimal :strike_4
      t.decimal :strike_3
      t.decimal :strike_2
      t.decimal :underlying
      t.decimal :five_three_val_m
      t.decimal :four_three_val_m
      t.decimal :three_two_val_m
      t.decimal :five_three_val_t
      t.decimal :four_three_val_t
      t.decimal :three_two_val_t
      t.decimal :five_three_val_w
      t.decimal :four_three_val_w
      t.decimal :three_two_val_w
      t.decimal :five_three_val_th
      t.decimal :four_three_val_th
      t.decimal :three_two_val_th
      t.decimal :five_three_val_f
      t.decimal :four_three_val_f
      t.decimal :three_two_val_f

      t.timestamps
    end
  end
end
