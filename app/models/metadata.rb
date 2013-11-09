require 'erb'

class Group
  attr_accessor :name
  attr_accessor :properties

  def initialize
    @name = nil
    @properties = []
  end

  def add_property(var, name, property_type = :string)
    group_property = GroupProperty.new(var, name, property_type)
    @properties << group_property
    self
  end
end

class GroupProperty
  attr_accessor :property_var
  attr_accessor :property_name
  attr_accessor :property_type

  def initialize(var, name, property_type)
    @property_var = var
    @property_name = name
    @property_type = property_type

    @property_type_map = {
      :string => 'text_field',
      :text => 'text_area',
      :boolean => 'check_box',
      :password => 'password_field',
      :telephone => 'telephone_field',
      :phone => 'telephone_field',
      :date => 'date_field',
      :datetime => 'datetime_field',
      :month => 'month_field',
      :week => 'week_field',
      :email => 'email_field',
      :color => 'color_field',
      :time => 'time_field'
    }
  end

  def get_input_control
    # For example:
    # '<input name="validation"/>'.html_safe

    prop_type = @property_type_map[@property_type]
    raise "Property '#{@property_type}' is not mapped to a Rails form input control" if prop_type.nil?

    # However, this is very cool:
    # http://stackoverflow.com/questions/18115669/how-to-insert-string-into-an-erb-file-for-rendering-in-rails-3-2
    "<%= f.#{prop_type} '#{@property_var}'%>"
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

  def initialize
    @property_grid_content = PropertyGridContent.new().add_group('Group A') do |group|
      group.add_property(:prop_a, 'Prop A').add_property(:prop_b, 'Prop B')
    end.add_group('Group B') do |group|
      group.add_property(:prop_c, 'Prop C', :string).add_property(:prop_d, 'Prop D')
    end

    @prop_a = 'a'
    @prop_b = 'b'
    @prop_c = Date.new(1962, 8, 19)
    @prop_d = 'd'
  end
end
