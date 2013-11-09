# A field type defines computations, validations, and other state information.
# The field type can also map to objects responsible for the display (formatting) and input of the field.
# This may visually be represented as multiple fields, like "weight" being represented by "lbs" and "oz"
class AddMetadataFieldTypesTable < ActiveRecord::Migration
  def change
    create_table :metadata_field_types do |t|
      t.string :type_name, null: false    # if no type name is specified, then the type defaults to "[table_name]-[field_name]"
      t.text :computation                 # computation (this is a read-only field by default and is added to the table's fields)
      t.text :validation                  # additional validations not part of DB capabilities
      t.boolean :read_only                # specifies a read-only field
      t.boolean :hidden
      t.timestamps
    end

    add_index :metadata_field_types, :type_name, unique: true
  end
end
