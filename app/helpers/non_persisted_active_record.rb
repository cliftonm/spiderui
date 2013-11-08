# A class that behaves like an ActiveRecord, so we can use it in form_for, but isn't actually persisted.
class NonPersistedActiveRecord
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  # Required by ActiveModel::Naming to tell it we're not persisting the model.
  def persisted?
    false
  end
end