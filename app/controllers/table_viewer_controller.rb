include MyUtils

MAIN_TABLE_ROWS = 20
FK_ROWS = 7

class TableViewerController < ApplicationController
  attr_reader :data_table
  attr_reader :parent_tables
  attr_reader :child_tables
  attr_reader :parent_dataset
  attr_reader :child_dataset

  attr_session_accessor :table_name
  attr_session_accessor :qualifier
  attr_session_accessor :breadcrumbs
  attr_session_accessor :last_page_num
  attr_session_accessor :force_page_num
  attr_session_accessor :model_page_nums    # dictionary of page numbers for all the models being displayed.
  attr_session_accessor :parent_qualifiers  # hash of table name => qualifier
  attr_session_accessor :child_qualifiers   # has of table name => qualifier

  # The main page.
  # If a :table_name exists in the session, then the table data is loaded and displayed, as well as the
  # parent/child navigation options.
  def index
    # constants that never change for the database (unless of course the DB schema itself changes)
    initialize_attributes
    update_model_page_numbers

    if self.table_name
      restore_page_number_on_nav                                                  # restores the page number when navigating back along the breadcrumbs
      self.last_page_num = self.model_page_nums[self.table_name+'_page']          # preserve the page number so selected navigation records are selected from the correct page.
      @data_table = load_DDO(self.table_name, self.last_page_num, self.qualifier, MAIN_TABLE_ROWS)
      add_hidden_index_values(@data_table)
      load_navigators(self.table_name)
      @parent_dataset = load_fk_tables(@parent_tables, self.parent_qualifiers)
      @child_dataset = load_fk_tables(@child_tables, self.child_qualifiers)
      # Update the parent tab index based on the existence and value of the selected_parent_table_index parameter
      update_parent_child_tab_indices
    end
  end

  # for debugging, clear all session information.
  def clear_session
    self.breadcrumbs = nil
    self.table_name = nil
    self.qualifier = nil
    self.model_page_nums = nil
    self.parent_qualifiers = nil
    self.child_qualifiers = nil

    redirect_to :root
  end

  # Respond to a user selecting a table.  We store the table name in the session and redirect to the index page.
  def view_table

    self.qualifier = nil        # clear out the current qualifier
    clear_model_qualifiers
    clear_model_page_nums
    self.table_name = params[:table_name]
    create_breadcrumb_trail(params[:table_name])

    redirect_to table_viewer_path+"/index"
  end

  # Respond to the user navigating to a parent or child.
  # We store the appropriate table name in the session and redirect to the index page.
  def post
    current_table = self.table_name

    if params[:navigate_to_parent]
      clear_model_qualifiers
      target_table = params[:cbParents]
      selected_records = []
      selected_records = get_selected_records(self.table_name, params[:selected_records], self.qualifier) if params[:selected_records]
      # If items in the current table are selected, then these are FK's to the parent table.
      # While this is straight forward if there is one FK column (we can use a "where PK in ()" clause),
      # for composite FK's this probably requires individual queries.  For the moment, we can either
      # disallow composite FK navigation or allow only zero or one record to be selected to navigate to the parent data
      # in the case of a composite FK.
      qualifier = get_parent_qualifier(current_table, target_table, selected_records)
      navigating_to(target_table, qualifier)
    elsif params[:navigate_to_child]
      clear_model_qualifiers
      target_table = params[:cbChildren]
      selected_records = []
      selected_records = get_selected_records(self.table_name, params[:selected_records], self.qualifier) if params[:selected_records]
      # If items in the current table are selected, then these are PK's.  The child table will have FK's to specific
      # PK columns.
      qualifier = get_child_qualifier(current_table, target_table, selected_records)
      navigating_to(target_table, qualifier)
    elsif params[:navigate_show_all]
      # Show all records for the current navigation point
      self.qualifier = nil
      clear_model_qualifiers
    elsif params[:qualify_by_selection]
      # Qualify all parent and child tables by the current selection.
      selected_records = []
      selected_records = get_selected_records(self.table_name, params[:selected_records], self.qualifier) if params[:selected_records]

      if selected_records.empty?
        flash[:error] = "Please select some records from the user table on the left."
      else
        clear_model_qualifiers
        clear_model_page_nums_except(self.table_name)
        load_navigators(self.table_name)      # Parent_tables and child_tables need to be loaded first.
        qualify_parent_records(self.table_name, selected_records)
        qualify_child_records(self.table_name, selected_records)
      end
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

  # Clear parent and child model qualifiers.
  def clear_model_qualifiers
    self.parent_qualifiers = {}
    self.child_qualifiers = {}
  end

  # Clear the page numbers being displayed for all the models
  def clear_model_page_nums
    self.model_page_nums = {}
  end

  # Clear the page numbers being displayed for all the models except the one specified
  def clear_model_page_nums_except(table_name)
    model_page_nums.each do |k,v |
      model_page_nums[k] = 1 unless k==table_name + '_page'
    end
  end

  # stores the selected parent table index if the selected_parent_table_index exists.  It will exist
  # when the paginator is used.
  def update_parent_child_tab_indices
      @parent_tab_index = params[:selected_parent_table_index].to_i if params[:selected_parent_table_index]
      @parent_tab_index ||= 0     # if it doesn't exist, set it to 0.
      @child_tab_index = params[:selected_child_table_index].to_i if params[:selected_child_table_index]
      @child_tab_index ||= 0     # if it doesn't exist, set it to 0.
  end

  # If the user clicked on a page number, update the model-pagenum dictionary to reflect the new page number
  # that the user has clicked on.  All page number params are of the format [schema].[table_name]_[page_number]
  def update_model_page_numbers
    model_page_nums = self.model_page_nums
    page_num_keys = params.select { |k, v| k =~/^[a-zA-Z0-9]+.[a-zA-Z0-9]+_page$/}

    page_num_keys.each do |page_num_key|
      model_page_nums[page_num_key[0]] = page_num_key[1]
    end

    self.model_page_nums = model_page_nums
  end

  # Initialize attributes, assuming no table is selected and no navigation possible.
  def initialize_attributes
    @table_viewer = DynamicTable.new
    # TODO: Now that we're using sqlite3 for session info, persisting @table might be faster?
    @tables = case_insensitive_sort(Schema.get_user_tables)
    @table_name = nil
    @parent_tables = []
    @child_tables = []
    @breadcrumbs = self.breadcrumbs                              # we need to explicitly load up this attribute from the session store

    if self.parent_qualifiers.nil?
      self.parent_qualifiers = {}
    end

    if self.child_qualifiers.nil?
      self.child_qualifiers = {}
    end
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
    parents = Schema.get_parent_table_info_for(table_name)
    @parent_tables = format_for_combo_box(parents, :ReferencedSchemaName, :ReferencedTableName)
    children = Schema.get_child_table_info_for(table_name)
    @child_tables = format_for_combo_box(children, :SchemaName, :TableName)
  end

  # Given an array of fk (parent or child) tables (OpenStruct with id and name properties), return an array of DataTables
  # of data for each parent/child table.
  def load_fk_tables(tables, qualifiers)
    dataset = []

    tables.each_with_index do |table, index|
      qualifier = qualifiers[table.name]
      data_table = load_DDO(table.name, self.model_page_nums[table.name+'_page'], qualifier, FK_ROWS)
      # Preserve the index so we can select the tab again when the page refreshes
      data_table.index = index
      dataset << data_table
    end

    dataset
  end

  # Add hidden index values so we can identify uniquely selected rows in 'post'
  def add_hidden_index_values(data_table)
    data_table.records.each_with_index do |record, index|
      record.__idx = index
    end
  end

  # Returns an array of DynamicTable instances for the selected record indexes
  def get_selected_records(table_name, selected_record_indexes, qualifier)
    selected_records = []
    data_table = load_DDO(table_name, self.last_page_num, qualifier, MAIN_TABLE_ROWS)         # get the records for the current page.

    # indexes always start with 0 regardless of what page we're on.
    selected_record_indexes.each do |idx|
      selected_records << data_table.records[idx.to_i]
    end

    selected_records
  end

  # Load all parent records qualified by the selected records.
  def qualify_parent_records(current_table, selected_records)
    parent_qualifiers = {}

    parent_tables.each do |table|
      qualifier = get_parent_qualifier(current_table, table.name, selected_records)
      parent_qualifiers[table.name] = qualifier
    end

    self.parent_qualifiers = parent_qualifiers
  end

  # Load all child records qualified by the selected records.
  def qualify_child_records(current_table, selected_records)
    child_qualifiers = {}

    child_tables.each do |table|
      qualifier = get_child_qualifier(current_table, table.name, selected_records)
      child_qualifiers[table.name] = qualifier
    end

    self.child_qualifiers = child_qualifiers
  end

  # Returns the qualifier for the relationship between the current table and the target table for the selected records.
  def get_parent_qualifier(current_table, target_table, selected_records)
    key_cols = get_key_columns(current_table, target_table)
    qualifier = create_value_qualifier(key_cols, selected_records, :parent, current_table, target_table)

    qualifier
  end

  # Returns the qualifier for the relationship between the current table and the target table for the selected records.
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
    return false if ['__rn', 'rowguid', 'ModifiedDate'].include?(field_name)
    true
  end

  # Fixes encoding to UTF-8 for certain field types that cause problems.
  # http://stackoverflow.com/questions/13003287/encodingundefinedconversionerror
  helper_method :fix_encoding
  def fix_encoding(value)
    value.to_s.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => '?'})
  end

  # Returns only the visible fields
  helper_method :get_visible_fields
  def get_visible_fields(data_table)
    data_table.fields.keep_if {|f| display_field?(data_table.table_name, f)}
  end

  helper_method :last_column
  def last_column(visible_fields, field_index)
    return field_index == visible_fields.length - 1
  end
end
