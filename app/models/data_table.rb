# DataTable manages the records, fields, table name, and other attributes of a table!
class DataTable
  attr_accessor :table_name
  attr_accessor :records
  attr_accessor :fields

  def initialize(table_name, records, fields)
    @table_name = table_name
    @records = records
    @fields = fields
  end
end