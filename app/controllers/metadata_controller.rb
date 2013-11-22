include MyUtils
include PropertyGrid

class MetadataController < ApplicationController
  attr_session_accessor :metadata_table_name
  attr_session_accessor :metadata_field_name

  attr_accessor :javascript
  attr_accessor :property_grid
  attr_accessor :metadata_field_type

  def index
    initialize_table_list
    initialize_fields
    initialize_field_types
  end

  def post
    redirect_to metadata_path+"/index"
  end

  def select_table
    self.metadata_table_name = params[:table_name]
    redirect_to metadata_path+"/index"
  end

  def select_field
    self.metadata_field_name = params[:field_name]
    redirect_to metadata_path+"/index"
  end

  private

  # If a table has been selected, get the field list
  def initialize_fields
    if self.metadata_table_name
      @fields = Schema.get_table_fields(@metadata_table_name)
    end
  end

  # If a field has been selected, get the type information
  def initialize_field_types
    if self.metadata_field_name
      @metadata_field_type = load_or_create_field_type(self.metadata_table_name, self.metadata_field_name)
      initialize_metadata_property_grid
    end
  end

  def initialize_table_list
    @tables = case_insensitive_sort(Schema.get_user_tables)      # Too large to save in a session!  This is annoying because we're loading this from the DB every single time!!!
  end

  # Creates an instance of APropertyGrid in @property_grid
  def initialize_metadata_property_grid
    @property_grid = new_property_grid
    group 'Field Type'
    group_property 'Type Name', :type_name
    group_property 'Display Name', :display_name
    group 'Display / Edit'
    group_property 'Hidden', :hidden, :boolean
    group_property 'Read Only', :read_only, :boolean
    group 'Computations'
    group_property 'Validation', :validation
    group_property 'Computed', :computation

    @javascript = generate_javascript_for_property_groups(@property_grid)
  end

  # Returns a MetadataFieldType instance.
  def load_or_create_field_type(table_name, field_name)
    field_type = MetadataFieldType.new()
    field_type.type_name = table_name + '.' + field_name
    field_type.display_name = field_name
    field_type.hidden = true
    field_type.read_only = true
    field_type.computation='foobar'
    field_type.validation='fizbin'

    field_type
  end
end
