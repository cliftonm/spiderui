module MyUtils
  # Returns the current database config has a dictionary of string => string
  def get_current_database_config
    Rails.configuration.database_configuration[Rails.env]
  end

  # Gets the specified query from the config.yml file
  # Example: sql = get_query("Schema", "user_tables")
  # TODO: cache keys
  def get_query(key1, key2)
    sql = YAML.load_file(File.expand_path('config/queries.yml'))
    sql[key1][key2]
  end

  # Given a dictionary of string => string, returns :symbol => string
  # Example: config_as_symbol = symbolize_hash_key(config)
  def symbolize_hash_key(hash)
    hash.each_with_object({}){|(k,v), h| h[k.to_sym] = v}
  end

  # gets the specified column values from the array of arrays.
  # Example: get_column(records, 0)
  # This returns all the values in column 0 for all the rows in 'records'
  def get_column(array_of_arrays, idx)
    array_of_arrays.map{|r| r[idx]}
  end

  # Does a case-insensitive sort of an array of strings.
  # Example: @tables = case_insensitive_sort(Schema.user_tables)
  def case_insensitive_sort(array)
    array.sort{|a, b| a.downcase <=> b.downcase}
  end

  # create a client connection.
  def create_db_client
    config = get_current_database_config
    config_as_symbol = symbolize_hash_key(config)
    client = TinyTds::Client.new(config_as_symbol)

    client
  end

  # Loads the Dynamic Data Object with data and field names
  # Returns a DataTable instance
  def load_DDO(table_name, page = 1, where = nil)
    raise "Table name cannot be nil" if table_name.nil?
    table = DynamicTable.new
    table.set_table_data(table_name)

    if where
      records = DynamicTable.where(where).paginate(page: page, per_page: 25)
    else
      records = DynamicTable.paginate(page: page, per_page: 25)
    end
    fields = table.get_record_fields(records)

    return DataTable.new(table_name, records, fields)
  end

  # Given two arrays of equal length, 'keys' and 'values', returns a hash of key => value
  def hash_from_key_value_arrays(keys, values)
    Hash[keys.zip values]
  end

  # If it exists, return the object in the session referenced by key.
  # If it doesn't exist, create it from the specified block, store it in the session, and return it.
  def find_or_create_in_session(session, key, &block)
    obj = session[key]

    if obj.nil?
      if !block.nil?
        obj = block.call
        session[key] = obj
      else
        raise "Block must be provided to create the session key #{key}"
      end
    end

    obj
  end

end
