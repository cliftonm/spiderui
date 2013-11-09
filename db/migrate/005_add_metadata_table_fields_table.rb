class AddMetadataTableFieldsTable < ActiveRecord::Migration
  def change
    create_table :metadata_table_fields do |t|
      t.integer :table_id, null: true, references: :metadata_tables    # if only null table_id exists, then this applies to all fields with the same name across all tables.
      t.string :field_name, null: false
      t.integer :field_type_id, references: :metadata_field_types    # selected from a list of defined field types
      t.timestamps
    end

   add_index :metadata_table_fields, [:table_id, :field_name], unique: true
  end
end
