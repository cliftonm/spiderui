include MyUtils

class TableViewerController < ApplicationController
  attr_reader :records
  attr_reader :fields
  attr_reader :parent_tables
  attr_reader :child_tables
  attr_reader :breadcrumbs

  # The main page.
  # If a :table_name exists in the session, then the table data is loaded and displayed, as well as the
  # parent/child navigation options.
  def index
    # constants that never change for the database (unless of course the DB schema itself changes)
    @table_viewer = DynamicTable.new
    @tables = case_insensitive_sort(Schema.user_tables)          # Too large to save in a session!  This is annoying because we're loading this from the DB every single time!!!
    @table_name = nil
    load_table_data(session[:table_name]) if session[:table_name]
    @breadcrumbs = find_or_create_in_session(session, :breadcrumbs) {[]}
  end

  # Respond to a user selecting a table.  We store the table name in the session and redirect to the index page.
  def view_table
    session[:table_name] = params[:table_name]
    create_breadcrumb_trail(params[:table_name])
    redirect_to table_viewer_path+"/index"
  end

  # Respond to the user navigating to a parent or child.
  # We store the appropriate table name in the session and redirect to the index page.
  def post
    if params[:navigate_to_parent]
      target_table = params[:cbParents]
      # If items in the current table are selected, then these are FK's to the parent table.
      # While this is straight forward if there is one FK column (we can use a "where PK in ()" clause),
      # for composite FK's this probably requires individual queries.  For the moment, we can either
      # disallow composite FK navigation or allow only zero or one record to be selected to navigate to the parent data
      # in the case of a composite FK.
    end

    if params[:navigate_to_child]
      target_table = params[:cbChildren]
      # If items in the current table are selected, then these are PK's.  The child table will have FK's to specific
      # PK columns.
    end

    session[:table_name] = target_table
    add_to_breadcrumb_trail(target_table)
    redirect_to table_viewer_path+"/index"
  end

  # Navigate back to the selected table in the nav history and pop the stack to that point.
  def nav_back
    stack_idx = params[:index].to_i
    @breadcrumbs = find_or_create_in_session(session, :breadcrumbs) {[]}
    session[:table_name] = @breadcrumbs[stack_idx]
    @breadcrumbs = @breadcrumbs[0..stack_idx]
    session[:breadcrumbs] = @breadcrumbs

    redirect_to table_viewer_path+"/index"
  end

  private

  def create_breadcrumb_trail(target_table)
    @breadcrumbs = [target_table]
    session[:breadcrumbs] = @breadcrumbs
  end

  def add_to_breadcrumb_trail(target_table)
    @breadcrumbs = find_or_create_in_session(session, :breadcrumbs) {[]}
    @breadcrumbs.push(target_table)
    session[:breadcrumbs] = @breadcrumbs
  end

  def load_table_data(table_name)
    # Initialize with empty arrays in case no table has been defined yet.
    @parent_tables = []
    @child_tables = []
    @table_name = table_name

    load_DDO(@table_name)
    records = Schema.load_parents(@table_name)
    @parent_tables = format_for_combo_box(records, :ReferencedSchemaName, :ReferencedTableName)
    records = Schema.load_children(@table_name)
    @child_tables = format_for_combo_box(records, :SchemaName, :TableName)
  end

  # Formats the child and parent records to something suitable for a 'select_tag', namely a struct which has 'id' and 'name' attributes.
  def format_for_combo_box(records, schema, field)
    array = []
    already_seen = []
    records.each { |record|
      parent = OpenStruct.new
      schema_field = record[schema] + '.' + record[field]

      if !already_seen.include?(schema_field)
        parent.id = schema_field
        parent.name = schema_field
        array << parent
        already_seen << schema_field
      end
    }

    array
  end

  # Return true if the field can be displayed.
  # All sorts of interesting things can be done here:
  #   Hide primary keys, ModifiedDate, rowguid, etc.

  helper_method :display_field?
  def display_field?(table_name, field_name)
    # '__rn' is something that will_paginate adds.
    return false if ['__rn', 'rowguid', 'ModifiedDate'].include?(field_name)
    true
  end

  # Fixes encoding to UTF-8 for certain field types that cause problems.
  # http://stackoverflow.com/questions/13003287/encodingundefinedconversionerror
  helper_method :fix_encoding
  def fix_encoding(value)
    value.to_s.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => '?'})
  end
end
