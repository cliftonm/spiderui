# Container for a foreign key and primary key table_field instance
class TableFieldPair
  attr_accessor :fk_table_field
  attr_accessor :pk_table_field

  def initialize(fk_table_field, pk_table_field)
    @fk_table_field = fk_table_field
    @pk_table_field = pk_table_field
  end
end