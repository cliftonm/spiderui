# Use the sqlite3 database for storing metadata about the database we're connecting to.
# http://stackoverflow.com/questions/1226182/how-do-i-work-with-two-different-databases-in-rails-with-active-records
class MetadataActiveRecord < ActiveRecord::Base
  self.abstract_class = true
  establish_connection(:sessions)
end

