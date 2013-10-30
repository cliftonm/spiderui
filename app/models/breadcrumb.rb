# Tracks a breadcrumb, which involves the table name, its qualifier, and the page number the user was viewing
class Breadcrumb
  attr_accessor :table_name
  attr_accessor :qualifier
  attr_accessor :page_num

  def initialize(table_name, qualifier = nil)
    @table_name = table_name
    @qualifier = qualifier
    @page_num = page_num
  end
end