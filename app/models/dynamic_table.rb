class DynamicTable < ActiveRecord::Base
  attr_writer :__idx      # Used internally to create a primary key on paginated table data.

  # Returns an array of records for the specified table.
  def set_table_data(table_name)
    DynamicTable::table_name = table_name
  end

  # Returns the field names given at least one record.
  def get_record_fields(records)
    fields = []
    fields = records[0].attributes.keys if records.count > 0

    fields
  end
end
