require "test/unit"

require File.dirname(__FILE__) + '/../lib/metafun/eigenclass'

class EigenclassTest < Test::Unit::TestCase
  def test_should_get_eigenclass_of_object
    o = Object.new
    o_eigen = (class << o; self; end)
    assert_not_equal o, o_eigen
    assert_equal o_eigen, o.eigenclass
  end
  
  def test_should_get_eigenclass_of_class
    assert_not_equal String, String.eigenclass
    assert_equal (class << String; self; end), String.eigenclass
  end
  
  def test_should_get_eigenclass_of_object_singleton
    o = Object.new
    o_singleton = (class << o; self; end)
    assert_equal o.eigenclass, o_singleton
    assert_equal (class << o_singleton; self; end), o_singleton.eigenclass
  end
  
  def test_should_get_eigenclass_of_class_singleton
    c_singleton = (class << String; self; end)
    assert_not_equal String, c_singleton
    assert_not_equal c_singleton, c_singleton.eigenclass
  end
end