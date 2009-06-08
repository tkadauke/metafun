class Class
  def superclasses
    self.ancestors.select { |cls| cls.class == Class }
  end
  
  def supereigenclasses
    superclasses.collect { |cls| cls.eigenclass }
  end
  
  def reachable_modules
    self.extended_modules
  end
end

class Object
  def extended_modules
    eigenclass.ancestors.select { |mod| mod.class == Module }
  end
  
  def reachable_modules
    (self.extended_modules + self.class.included_modules)
  end
end
