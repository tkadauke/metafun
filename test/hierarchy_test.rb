require "test/unit"

require File.dirname(__FILE__) + '/../lib/metafun/hierarchy'

class HierarchyTest < Test::Unit::TestCase
  module First
  end
  
  module Second
  end
  
  class Base
    include First
  end
  
  class Derived < Base
    extend Second
  end
  
  def test_should_get_class_hierarchy
    assert_equal [Derived, Base, Object], Derived.class_hierarchy
  end
  
  def test_should_get_superclasses
    assert_equal [Base, Object], Derived.superclasses
  end
  
  def test_should_get_eigenclass_hierarchy
    assert_equal [Derived.eigenclass, Base.eigenclass, Object.eigenclass], Derived.eigenclass_hierarchy
  end
  
  def test_should_get_supereigenclasses
    assert_equal [Base.eigenclass, Object.eigenclass], Derived.supereigenclasses
  end
  
  def test_should_get_extended_modules_for_class
    assert Derived.extended_modules.include?(Second)
    assert !Derived.extended_modules.include?(First)
  end
  
  def test_should_get_usable_modules_for_class
    assert Derived.usable_modules.include?(Second)
    assert Derived.usable_modules.include?(Kernel)
  end
  
  def test_should_get_extended_modules_for_object
    o = Object.new
    o.extend First
    assert o.extended_modules.include?(First)
  end
  
  def test_should_get_usable_modules_for_object
    o = Derived.new
    assert o.usable_modules.include?(First)
    assert o.usable_modules.include?(Kernel)
  end
end
