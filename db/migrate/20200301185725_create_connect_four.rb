class CreateConnectFour < ActiveRecord::Migration[5.2]
  def change
    create_table :connect_fours do |t|
      t.string :board, null: false

      t.bigint :player1_id, null: false
      t.bigint :player2_id, null: false

      t.timestamps
    end
    add_index :connect_fours, :player1_id
    add_index :connect_fours, :player2_id
    add_index :connect_fours, [:player1_id, :player2_id], unique: true
  end
end
