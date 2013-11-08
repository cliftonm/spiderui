require 'tiny_tds'
include MyUtils

class Schema
  # Returns an array of strings containing the user tables in the database to which we're connecting.
  def self.get_user_tables
    client = create_db_client
    sql = get_query("Schema", "user_tables")
    result = client.execute(sql)
    records = result.each(as: :array, symbolize_keys: true)
    names = get_column(records, 0)

    names
  end

  def self.get_table_fields(table_name)
    client = create_db_client
    sql = get_query("Schema", "get_table_fields")
    sql.sub!('[schema]', table_name.partition('.')[0])
    sql.sub!('[table]', table_name.partition('.')[2])
    result = client.execute(sql)
    records = result.each(as: :array, symbolize_keys: true)
    field_names = get_column(records, 0)

    field_names
  end

  # Returns an array of hashes (column name => value) of the parent table schemas of the specified table.
  def self.get_parent_table_info_for(table_name)
    sql = get_query("Schema", "get_parents")
    sql.sub!('[table]', table_name.partition('.')[2])
    execute(sql)
  end

  # Returns an array of hashes (column name => value) of the child table schemas of the specified table.
  def self.get_child_table_info_for(table_name)
    sql = get_query("Schema", "get_children")
    sql.sub!('[table]', table_name.partition('.')[2])
    execute(sql)
  end

  def self.get_key_fields(child_table, parent_table)
    sql = get_query("Schema", "get_key_fields")
    # TODO: We should be using the qualified object ID, as this is ignoring the schema!
    sql.sub!('[childtable]', child_table.partition('.')[2])
    sql.sub!('[parenttable]', parent_table.partition('.')[2])
    execute(sql)
  end

  # Returns an array of fields for the specified table by doing a "where 1=0" query.
  def self.get_fields(table_name)
    sql = get_query("Schema", "get_fields")
    sql.sub!('[table]', table_name)
    client = create_db_client
    result = client.execute(sql)

    result.fields
  end

  private

  # Execute the query and return the result as an array of key=>value hashes.
  def self.execute(sql)
    client = create_db_client
    result = client.execute(sql)
    records = result.each(as: :array, symbolize_keys: true)
    array = convert_to_array_of_hashes(result.fields, records)

    array
  end

  # Convert the array of records from the TinyTDS query into an array of hashes, where
  # the keys are the field names.
  def self.convert_to_array_of_hashes(fields, records)
    array = []
    records.each { |record|
      dict = hash_from_key_value_arrays(fields, record)
      array << dict
    }

    array
  end
end

# Notes:

# while this works if the class is derived from ActiveRecord::Base, we also need the schema name for each table name
# self.where("type_desc = 'USER_TABLE'")

# for some reason, this returns -1, so we have to go to TinyTds directly:
=begin
    result = ActiveRecord::Base.establish_connection(config)
    records = ActiveRecord::Base.connection.execute("
      select s.name + '.' + o.name as table_name from sys.objects o
      left join sys.schemas s on s.schema_id = o.schema_id
      where type_desc = 'USER_TABLE'
      order by s.name + '.' + o.name")
=end

