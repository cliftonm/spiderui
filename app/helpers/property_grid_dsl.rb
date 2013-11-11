module PropertyGridDsl
  def new_property_grid(name = nil)
    @__property_grid = PropertyGrid.new

    @__property_grid
  end

  def group(name)
    group = Group.new
    group.name = name
    @__property_grid.groups << group

    group
  end

  def group_property(name, var, type = :string, collection = nil)
    group_property = GroupProperty.new(var, name, type, collection)
    @__property_grid.groups.last.properties << group_property

    group_property
  end
end
