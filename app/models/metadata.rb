require 'erb'
include PropertyGridDsl

class ControlType
  attr_accessor :type_name
  attr_accessor :class_name

  def initialize(type_name, class_name = nil)
    @type_name = type_name
    @class_name = class_name
  end
end

def get_property_type_map
  {
      string: ControlType.new('text_field'),
      text: ControlType.new('text_area'),
      boolean: ControlType.new('check_box'),
      password: ControlType.new('password_field'),
      date: ControlType.new('datepicker'),
      datetime: ControlType.new('text_field', 'jq_dateTimePicker'),
      time: ControlType.new('text_field', 'jq_timePicker'),
      color: ControlType.new('text_field', 'jq_colorPicker'),
      list: ControlType.new('select'),
      db_list: ControlType.new('select')
  }
end

# Defines a PropertyGrid group
# A group has a name and a collection of properties.
class Group
  attr_accessor :name
  attr_accessor :properties

  def initialize
    @name = nil
    @properties = []
  end

  def add_property(var, name, property_type = :string, collection = nil)
    group_property = GroupProperty.new(var, name, property_type, collection)
    @properties << group_property
    self
  end
end

class GroupProperty
  attr_accessor :property_var
  attr_accessor :property_name
  attr_accessor :property_type
  attr_accessor :property_collection

  # some of these leverage jquery: http://jqueryui.com/

  def initialize(var, name, property_type, collection = nil)
    @property_var = var
    @property_name = name
    @property_type = property_type
    @property_collection = collection
  end

  def get_input_control
    form_type = get_property_type_map[@property_type]
    raise "Property '#{@property_type}' is not mapped to a Rails form input control" if form_type.nil?

    erb = "<%= f.#{form_type.type_name} :#{@property_var}"
    erb << ", class: '#{form_type.class_name}'" if form_type.class_name.present?
    erb << ", #{@property_collection}" if @property_collection.present? && @property_type == :list
    erb << ", options_from_collection_for_select(f.object.records, :id, :name, f.object.#{@property_var})" if @property_collection.present? && @property_type == :db_list
    erb << "%>"
  end
end

# A PropertyGrid container
# A property grid consists of property groups.
class PropertyGrid
  attr_accessor :groups

  def initialize
    @groups = []
  end

  # Give a group name, creates a group.
  def add_group(name)
    group = Group.new
    group.name = name
    @groups << group
    yield(group)          # yields to block creating group properties
    self                  # returns the PropertyGrid instance
  end
end

class ARecord
  attr_accessor :id
  attr_accessor :name

  def initialize(id, name)
    @id = id;
    @name = name
  end
end

class Metadata < NonPersistedActiveRecord
  attr_accessor :property_grid

  attr_accessor :prop_a
  attr_accessor :prop_b
  attr_accessor :prop_c
  attr_accessor :prop_d
  attr_accessor :prop_e
  attr_accessor :prop_f
  attr_accessor :prop_g
  attr_accessor :prop_h
  attr_accessor :prop_i
  attr_accessor :records

  def initialize
    @records =
        [
            ARecord.new(1, 'California'),
            ARecord.new(2, 'New York'),
            ARecord.new(3, 'Rhode Island'),
        ]
#=begin
    @property_grid = PropertyGrid.new().
      add_group('Text Input') do |group|
        group.add_property(:prop_a, 'Text').
            add_property(:prop_b, 'Password', :password)
      end.
      add_group('Date and Time Pickers') do |group|
        group.add_property(:prop_c, 'Date', :date).
            add_property(:prop_d, 'Time', :time).
            add_property(:prop_e, 'Date/Time', :datetime)
      end.
      add_group('State') do |group|
        group.add_property(:prop_f, 'Boolean', :boolean)
      end.
      add_group('Miscellaneous') do |group|
        group.add_property(:prop_g, 'Color', :color)
      end.
      add_group('Lists') do |group|
        group.add_property(:prop_h, 'Basic List', :list, ['Apples', 'Oranges', 'Pears']).
            add_property(:prop_i, 'ID - Name List', :db_list, @records)
      end
#=end
=begin
    @property_grid = new_property_grid
    group 'Text Input'
    group_property 'Text', :prop_a
    group_property 'Password', :prop_b, :password
    group 'Date and Time Pickers'
    group_property 'Date', :prop_c, :date
    group_property 'Time', :prop_d, :date
    group_property 'Date/Time', :prop_e, :datetime
    group 'State'
    group_property 'Boolean', :prop_f, :boolean
    group 'Miscellaneous'
    group_property 'Color', :prop_g, :color
    group 'Lists'
    group_property 'Basic List', :prop_h, :list, ['Apples', 'Oranges', 'Pears']
    group_property 'ID - Name List', :prop_i, :db_list, @records
=end

    @prop_a = 'Hello World'
    @prop_b = 'Password!'
    @prop_c = '08/19/1962'
    @prop_d = '12:32 pm'
    @prop_e = '08/19/1962 12:32 pm'
    @prop_f = true
    @prop_g = '#ff0000'
    @prop_h = 'Pears'
    @prop_i = 2
  end
end
