class DynamicTable < ActiveRecord::Base
  # Used internally to create a primary key on paginated table data.
  # Must be an attribute accessed as "record.__idx" rather than "record['__idx']" because:
  # writing arbitrary attributes on a model is deprecated.
  # See here:  https://github.com/rails/rails/commit/50d395f96ea05da1e02459688e94bff5872c307b
  attr_accessor :__idx

  # Returns an array of records for the specified table.
  def set_table_data(table_name)
    DynamicTable::table_name = table_name
  end
end
