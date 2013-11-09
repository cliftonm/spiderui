# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 5) do

  create_table "metadata_field_types", :force => true do |t|
    t.string   "type_name",   :null => false
    t.text     "computation"
    t.text     "validation"
    t.boolean  "read_only"
    t.boolean  "hidden"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "metadata_field_types", ["type_name"], :name => "index_metadata_field_types_on_type_name", :unique => true

  create_table "metadata_table_fields", :force => true do |t|
    t.integer  "table_id"
    t.string   "field_name",    :null => false
    t.integer  "field_type_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "metadata_table_fields", ["table_id", "field_name"], :name => "index_metadata_table_fields_on_table_id_and_field_name", :unique => true

  create_table "metadata_table_types", :force => true do |t|
    t.string   "type_name",         :null => false
    t.text     "fk_display_fields"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "metadata_table_types", ["type_name"], :name => "index_metadata_table_types_on_type_name", :unique => true

  create_table "metadata_tables", :force => true do |t|
    t.string   "table_name",    :null => false
    t.integer  "table_type_id", :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "metadata_tables", ["table_name"], :name => "index_metadata_tables_on_table_name", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

end
