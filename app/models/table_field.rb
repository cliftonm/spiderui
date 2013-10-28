# Container for a table name and field name
class TableField
  attr_accessor :table_name
  attr_accessor :field_name

  def initialize(table_name, field_name)
    @table_name = table_name
    @field_name = field_name
  end
end
