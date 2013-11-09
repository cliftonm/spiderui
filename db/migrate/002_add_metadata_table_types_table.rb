class AddMetadataTableTypesTable < ActiveRecord::Migration
  def change
    create_table :metadata_table_types do |t|
      t.string :type_name, null: false    # if no type name is specified, then the type defaults to "[table_name]"
      t.text :fk_display_fields           # display field and formatting, like "@city, @state"
      t.timestamps
    end

    add_index :metadata_table_types, :type_name, unique: true
  end
end
