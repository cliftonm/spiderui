# Tracks a breadcrumb, which involves the table name and its qualifier.
class Breadcrumb
  attr_accessor :table_name
  attr_accessor :qualifier

  def initialize(table_name, qualifier = nil)
    @table_name = table_name
    @qualifier = qualifier
  end
end