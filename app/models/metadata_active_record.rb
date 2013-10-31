# Use the sqlite3 database for storing metadata about the database we're connecting to.
# http://stackoverflow.com/questions/1226182/how-do-i-work-with-two-different-databases-in-rails-with-active-records
class MetadataActiveRecord < ActiveRecord::Base
  self.abstract_class = true
  establish_connection(:sessions)
end

# The additional models:
# metadata_table                    - table name (string), fk_display_fields (comma separated field names)
# metadata_field                    - field name (string), hidden (bool), fk_resolve (bool)
# metadata_table_field              - FK to table, field name (string), hidden (bool), fk_resolve (bool)

# entries in metadata_field are applied to any table with that field name, unless overridden by metadata_table_field
# fk_resolve of true indicates that the field value should be resolved with an fk lookup.
# fk_display_fields are the fields to display when the table is a FK reference in the order that they are listed

# Note:
# metadata_table_field does not reference metadata_field because the latter isn't really a PK for a field name,
#   rather it is globally applied when present - therefore this table will be sparesely populated rather than
#   representing each field in each table - in fact, it doesn't even have a table FK!  So it would be mixing
#   apples and oranges to have metadata_table_field FK to metadata_field.

