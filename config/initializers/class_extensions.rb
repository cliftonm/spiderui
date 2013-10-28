# Adds an "attr_session_accessor" declarator that, in addition to setting/getting the value
# to the attribute, it also gets/sets the value from the session.
# Usage inside the class defining the attribute:  self.foobar = 1
# Note that "self." must prefix the usage of the attribute.
class Class
  def attr_session_accessor(*args)
    args.each do |arg|
      self.class_eval("def #{arg}; @#{arg}=session['#{arg}']; end")
      self.class_eval("def #{arg}=(val); @#{arg}=val; session['#{arg}']=val; end")
    end
  end
end
