require "test/unit"

require File.dirname(__FILE__) + '/../lib/metafun/selfclass'

class SelfclassTest < Test::Unit::TestCase
  def test_should_get_selfclass_of_object
    o = Object.new
    assert_not_equal Object, o
    assert_equal Object, o.selfclass
  end
  
  def test_should_get_selfclass_of_class
    assert_equal String, String.selfclass
  end
  
  def test_should_get_selfclass_of_object_singleton
    o = Object.new
    o_singleton = (class << o; self; end)
    assert_not_equal Object, o
    assert_equal Object, o.selfclass
  end
  
  def test_should_not_get_selfclass_of_class_singleton
    c_singleton = (class << String; self; end)
    assert_not_equal String, c_singleton
    assert_not_equal String, c_singleton.selfclass
  end
end