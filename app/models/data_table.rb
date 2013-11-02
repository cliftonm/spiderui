# DataTable manages the records, fields, table name, and other attributes of a table!
class DataTable
  attr_accessor :table_name
  attr_accessor :records
  attr_accessor :fields
  attr_accessor :index          # Used internally to index lists of tables, etc.

  def initialize(table_name, records, fields, index = nil)
    @table_name = table_name
    @records = records
    @fields = fields
  end
end