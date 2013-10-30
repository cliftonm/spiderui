include MyUtils

class TableViewerController < ApplicationController
  attr_reader :records
  attr_reader :fields
  attr_reader :parent_tables
  attr_reader :child_tables

  attr_session_accessor :table_name
  attr_session_accessor :qualifier
  attr_session_accessor :breadcrumbs
  attr_session_accessor :last_page_num
  attr_session_accessor :force_page_num

  # The main page.
  # If a :table_name exists in the session, then the table data is loaded and displayed, as well as the
  # parent/child navigation options.
  def index
    # constants that never change for the database (unless of course the DB schema itself changes)
    initialize_attributes

    if self.table_name
      restore_page_number_on_nav                  # restores the page number when navigating back along the breadcrumbs
      self.last_page_num = params[:page]          # preserve the page number so selected navigation records are selected from the correct page.
      @records, @fields = load_DDO(self.table_name, self.last_page_num, self.qualifier)
      add_hidden_index_values(@records, @fields)
      load_navigators(self.table_name)
    end
  end

  # for debugging, clear all session information.
  def clear_session
    self.breadcrumbs = nil
    self.table_name = nil
    self.qualifier = nil

    redirect_to :root
  end

  # Respond to a user selecting a table.  We store the table name in the session and redirect to the index page.
  def view_table
    self.qualifier = nil   # clear out the current qualifier
    self.table_name = params[:table_name]
    create_breadcrumb_trail(params[:table_name])

    redirect_to table_viewer_path+"/index"
  end

  # Respond to the user navigating to a parent or child.
  # We store the appropriate table name in the session and redirect to the index page.
  def post
    current_table = self.table_name
    selected_records = []
    selected_records = get_selected_records(self.table_name, params[:selected_records], self.qualifier) if params[:selected_records]
    qualifier = nil         # assume no qualifier

    if params[:navigate_to_parent]
      target_table = params[:cbParents]
      # If items in the current table are selected, then these are FK's to the parent table.
      # While this is straight forward if there is one FK column (we can use a "where PK in ()" clause),
      # for composite FK's this probably requires individual queries.  For the moment, we can either
      # disallow composite FK navigation or allow only zero or one record to be selected to navigate to the parent data
      # in the case of a composite FK.
      qualifier = get_parent_qualifier(current_table, target_table, selected_records)
      navigating_to(target_table, qualifier)
    elsif params[:navigate_to_child]
      target_table = params[:cbChildren]
      # If items in the current table are selected, then these are PK's.  The child table will have FK's to specific
      # PK columns.
      qualifier = get_child_qualifier(current_table, target_table, selected_records)
      navigating_to(target_table, qualifier)
    elsif params[:navigate_show_all]
      # Show all records for the current navigation point
      self.qualifier = nil
    end

    redirect_to table_viewer_path+"/index"
  end

  # Navigate back to the selected table in the nav history and pop the stack to that point.
  # Use the qualifier that was specified when navigating to this table.
  # Restore the page number the user was previously on for this table.
  def nav_back
    stack_idx = params[:index].to_i
    breadcrumb = self.breadcrumbs[stack_idx]              # get the current breadcrumb
    self.table_name = breadcrumb.table_name               # we want to go back to this table and its qualifier
    self.qualifier = breadcrumb.qualifier
    self.breadcrumbs = self.breadcrumbs[0..stack_idx]     # remove all the other items on the stack
    self.force_page_num = breadcrumb.page_num

    redirect_to table_viewer_path+"/index"
  end

  private

  # Initialize attributes, assuming no table is selected and no navigation possible.
  def initialize_attributes
    @table_viewer = DynamicTable.new
    @tables = case_insensitive_sort(Schema.user_tables)          # Too large to save in a session!  This is annoying because we're loading this from the DB every single time!!!
    @table_name = nil
    @parent_tables = []
    @child_tables = []
    @breadcrumbs = self.breadcrumbs                              # we need to explicitly load up this attribute from the session store
  end

  # Create a breadcrumb trail array starting with the specified table.
  def create_breadcrumb_trail(table_name)
    self.breadcrumbs = [Breadcrumb.new(table_name)]
  end

  # Add the specified table to the breadcrumb trail
  def add_to_breadcrumb_trail(table_name, qualifier)
    breadcrumb = Breadcrumb.new(table_name, qualifier)
    self.breadcrumbs = self.breadcrumbs.push(breadcrumb)
  end

  # Updates the last breadcrumb in the stack with the current page number
  # so we can restore the page number when navigating back to that table.
  def update_page_num_of_current_breadcrumb(page_num)
    self.breadcrumbs[-1].page_num = page_num
  end

  def restore_page_number_on_nav
    if self.force_page_num
      params[:page] = self.force_page_num
      self.force_page_num = nil                   # clear the page number so it doesn't affect other navs.
    end
  end

  # Populates @parent_tables and @child_tables with the parent and child navigation options based on the FK's for
  # the specified table.
  def load_navigators(table_name)
    @parent_tables = []
    @child_tables = []
    parents = Schema.load_parents(table_name)
    @parent_tables = format_for_combo_box(parents, :ReferencedSchemaName, :ReferencedTableName)
    children = Schema.load_children(table_name)
    @child_tables = format_for_combo_box(children, :SchemaName, :TableName)
  end

  # Add hidden index values so we can identify uniquely selected rows in 'post'
  def add_hidden_index_values(records, fields)
    fields << '__idx'
    records.each_with_index do |record, index|
      record["__idx"] = index
    end
  end

  # Returns an array of DynamicTable instances for the selected record indexes
  def get_selected_records(table_name, selected_record_indexes, qualifier)
    selected_records = []
    records, fields = load_DDO(table_name, self.last_page_num, qualifier)         # get the records for the current page.

    # indexes always start with 0 regardless of what page we're on.
    selected_record_indexes.each do |idx|
      selected_records << records[idx.to_i]
    end

    selected_records
  end

  def get_parent_qualifier(current_table, target_table, selected_records)
    key_cols = get_key_columns(current_table, target_table)
    qualifier = create_value_qualifier(key_cols, selected_records, :parent, current_table, target_table)

    qualifier
  end

  def get_child_qualifier(current_table, target_table, selected_records)
    key_cols = get_key_columns(target_table, current_table)
    qualifier = create_value_qualifier(key_cols, selected_records, :child, current_table, target_table)

    qualifier
  end

  # returns an array of TableFieldPair instances (fk/pk table-col's) involved in the relationship.
  def get_key_columns(fk_table, pk_table)
    key_cols = Schema.get_key_fields(fk_table, pk_table)
    key_columns = []
    key_cols.each do |key|
      key_columns << TableFieldPair.new(
          TableField.new(fk_table, key[:ColName]),
          TableField.new(pk_table, key[:ReferencedColumnName]))
    end

    key_columns
  end

  def create_value_qualifier(key_cols, selected_records, type, current_table, target_table)
    clauses = []

    selected_records.each do |record|
      clauses << create_value_qualifier_for_record(key_cols, record, type, current_table, target_table)
    end

    # get unique clauses, then combine them with " or "
    clauses.uniq.join(' or ')
  end

  def create_value_qualifier_for_record(key_cols, record, type, current_table, target_table)
    ref_table = RefTable.new

    if type == :parent
      ref_table.table_name = current_table
      ref_table.parent_table_name = target_table
    else
      ref_table.table_name = target_table
      ref_table.parent_table_name = current_table
    end

    key_cols.each do |key|
      if type == :parent
        fk_col_name = key.fk_table_field.field_name
        pk_col_name = key.pk_table_field.field_name
      else
        fk_col_name = key.pk_table_field.field_name
        pk_col_name = key.fk_table_field.field_name
      end

      # convert all values to a string representation.
      ref_table.add_field_value(fk_col_name, pk_col_name, record[fk_col_name].to_s)
    end

    qualifier = ref_table.generate_qualifier(type)

    qualifier
  end

  # Formats the child and parent records to something suitable for a 'select_tag', namely a struct which has 'id' and 'name' attributes.
  def format_for_combo_box(records, schema, field)
    array = []
    already_seen = []
    records.each do |record|
      parent = OpenStruct.new
      schema_field = record[schema] + '.' + record[field]

      if !already_seen.include?(schema_field)
        parent.id = schema_field
        parent.name = schema_field
        array << parent
        already_seen << schema_field
      end
    end

    array
  end

  # We are navigating to the specified table with the specified qualifier.
  # Set the session info and add the new table and qualifier to the breadcrumb trail
  def navigating_to(table_name, qualifier)
    self.table_name = table_name
    self.qualifier = qualifier
    update_page_num_of_current_breadcrumb(self.last_page_num)
    add_to_breadcrumb_trail(table_name, qualifier)
  end

  # Return true if the field can be displayed.
  # All sorts of interesting things can be done here:
  #   Hide primary keys, ModifiedDate, rowguid, etc.
  helper_method :display_field?
  def display_field?(table_name, field_name)
    # '__rn' is something that will_paginate adds.
    # '__idx' is my hidden column for creating a single column unique ID to identify selected rows, since
    # we can't guarantee single-field PK's and we need some way to identify a row uniquely other than the actual data.
    return false if ['__rn', '__idx', 'rowguid', 'ModifiedDate'].include?(field_name)
    true
  end

  # Fixes encoding to UTF-8 for certain field types that cause problems.
  # http://stackoverflow.com/questions/13003287/encodingundefinedconversionerror
  helper_method :fix_encoding
  def fix_encoding(value)
    value.to_s.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => '?'})
  end

  # Returns only the visible fields
  helper_method :visible_fields
  def visible_fields
    fields.keep_if {|f| display_field?(self.table_name, f)}
  end
end
