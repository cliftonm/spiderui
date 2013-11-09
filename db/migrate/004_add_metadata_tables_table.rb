class AddMetadataTablesTable < ActiveRecord::Migration
  def change
    create_table :metadata_tables do |t|
      t.string :table_name, null: false
      t.integer :table_type_id, null: false, references: :metadata_table_types
      t.timestamps
    end

    add_index :metadata_tables, :table_name, unique: true
  end
end
