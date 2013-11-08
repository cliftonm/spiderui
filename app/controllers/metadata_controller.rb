include MyUtils

class MetadataController < ApplicationController
  attr_session_accessor :metadata_table_name
  attr_session_accessor :metadata_field_name

  def index
    initialize_attributes

    if self.metadata_table_name
      @fields = Schema.get_table_fields(@metadata_table_name)
    end
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
  end
end
