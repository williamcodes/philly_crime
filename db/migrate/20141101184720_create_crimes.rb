class CreateCrimes < ActiveRecord::Migration
  def change
    create_table :crimes do |t|
      t.integer :x
      t.integer :y
      t.string :text_general_code
      t.datetime :dispatch_date_time

      t.timestamps
    end
  end
end
