include MyUtils

class MetadataController < ApplicationController
  attr_session_accessor :metadata_table_name
  attr_session_accessor :metadata_field_name

  attr_accessor :javascript

  def index
    initialize_attributes

    if self.metadata_table_name
      @fields = Schema.get_table_fields(@metadata_table_name)
    end
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
  end

  def initialize_attributes
    @metadata = Metadata.new
    @tables = case_insensitive_sort(Schema.get_user_tables)      # Too large to save in a session!  This is annoying because we're loading this from the DB every single time!!!
    @metadata_table_name = nil
    @javascript = ''
    @metadata.property_grid.groups.each_with_index do |grp, index|
      @javascript << get_javascript_for_group(index)
    end
  end
end
