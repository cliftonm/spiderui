# A helper class to construct the query between a table and a parent table, given the field values for columns in the foreign key.
class RefTable
  attr_accessor :table_name
  attr_accessor :parent_table_name

  def initialize
    @field_values = []
  end

  def add_field_value(fk_field_name, pk_field_name, value)
    @field_values << FieldValue.new(fk_field_name, pk_field_name, value)
  end

  def generate_qualifier(type)
    qualifier = "("
    concat = ""
    concatenator = ""

    @field_values.each {|field_value|
      qualifier << concat

      if type == :parent
        qualifier << @parent_table_name + "." + field_value.pk_field_name
        # If the child has FK's that all reference the same PK of the parent, then this is not a composite key.
        # Instead, we have several fields all referencing the same PK of the parent.
        # TODO: What happens in cases where we have composite FK's as well as multiple singleton FK's referencing the same PK?
        concatenator = (@field_values.uniq {|f| f.pk_field_name}).length == 1 ? " or " : " and "
      else
        qualifier << @table_name + "." + field_value.pk_field_name
        # If the child has FK's that all reference the same PK of the parent, then this is not a composite key.
        # Instead, we have several fields all referencing the same PK of the parent.
        # TODO: What happens in cases where we have composite FK's as well as multiple singleton FK's referencing the same PK?
        concatenator = (@field_values.uniq {|f| f.fk_field_name}).length == 1 ? " or " : " and "
      end

      qualifier << " = '"
      qualifier << field_value.value
      qualifier << "'"
      concat = concatenator
    }

    qualifier << ")"

    qualifier
  end
end
