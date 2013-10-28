# Container for a value associated with a primary key column and foreign key column
class FieldValue
  attr_accessor :fk_field_name
  attr_accessor :pk_field_name
  attr_accessor :value

  def initialize(fk_field_name, pk_field_name, value)
    @fk_field_name = fk_field_name
    @pk_field_name = pk_field_name
    @value = value
  end
end