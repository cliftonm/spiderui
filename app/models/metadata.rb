require 'erb'

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

class FormType
  attr_accessor :type_name
  attr_accessor :class_name

  def initialize(type_name, class_name = nil)
    @type_name = type_name
    @class_name = class_name
  end
end

class GroupProperty
  attr_accessor :property_var
  attr_accessor :property_name
  attr_accessor :property_type
  attr_accessor :property_collection

  # some of these leverage jquery: http://jqueryui.com/

  def initialize(var, name, property_type, collection)
    @property_var = var
    @property_name = name
    @property_type = property_type
    @property_collection = collection

    @property_type_map = {
      :string => FormType.new('text_field'),
      :text => FormType.new('text_area'),
      :boolean => FormType.new('check_box'),
      :password => FormType.new('password_field'),
      :date => FormType.new('datepicker'),
      :datetime => FormType.new('text_field', 'jq_dateTimePicker'),
      :time => FormType.new('text_field', 'jq_timePicker'),
      :color => FormType.new('text_field', 'jq_colorPicker'),
      :list => FormType.new('select')
    }
  end

  def get_input_control
    # For example:
    # '<input name="validation"/>'.html_safe

    form_type = @property_type_map[@property_type]
    raise "Property '#{@property_type}' is not mapped to a Rails form input control" if form_type.nil?

    # However, this is very cool:
    # http://stackoverflow.com/questions/18115669/how-to-insert-string-into-an-erb-file-for-rendering-in-rails-3-2
    erb = "<%= f.#{form_type.type_name} '#{@property_var}'"
    erb << ", class: '#{form_type.class_name}'" if form_type.class_name.present?
    erb << ", #{@property_collection}" if @property_collection.present?
    erb << "%>"
  end
end

class PropertyGridContent
  attr_accessor :groups

  def initialize
    @groups = []
  end

  def add_group(name)
    group = Group.new
    group.name = name
    @groups << group
    yield(group)
    self
  end
end

class Metadata < NonPersistedActiveRecord
  attr_accessor :property_grid_content

  attr_accessor :prop_a
  attr_accessor :prop_b
  attr_accessor :prop_c
  attr_accessor :prop_d
  attr_accessor :prop_e
  attr_accessor :prop_f
  attr_accessor :prop_g
  attr_accessor :prop_h

  def initialize
    @property_grid_content = PropertyGridContent.new().
      add_group('Text Input') do |group|
        group.add_property(:prop_a, 'Text').
            add_property(:prop_b, 'Password', :password)
      end.
      add_group('Date and Time Pickers') do |group|
        group.add_property(:prop_c, 'Date', :date).
            add_property(:prop_d, 'Time', :time).
            add_property(:prop_e, 'Date-Time', :datetime)
      end.
      add_group('State') do |group|
        group.add_property(:prop_f, 'Boolean', :boolean)
      end.
      add_group('Miscellaneous') do |group|
        group.add_property(:prop_g, 'Color', :color)
        group.add_property(:prop_h, 'List', :list, ['Apples', 'Oranges', 'Pears'])
      end


    @prop_a = 'Hello World'
    @prop_b = 'Password!'
    @prop_c = '08/19/1962'
    @prop_d = '12:32 pm'
    @prop_e = '08/19/1962 12:32 pm'
    @prop_f = true
    @prop_g = '#ff0000'
    @prop_h = 'Oranges'
  end
end
