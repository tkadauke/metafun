require "test/unit"

require File.dirname(__FILE__) + '/../lib/metafun/ivar'

class IvarTest < Test::Unit::TestCase
  def test_should_get_instance_variable
    o = Object.new
    o.instance_variable_set(:@x, 10)
    ivar_object = Metafun::Ivar::Ivar.new(o)
    assert_equal 10, ivar_object[:"@x"]
  end
  
  def test_should_set_instance_variable
    o = Object.new
    assert_nil o.instance_variable_get(:"@x")
    ivar_object = Metafun::Ivar::Ivar.new(o)
    ivar_object[:@x] = 15
    assert_equal 15, o.instance_variable_get(:"@x")
  end
  
  def test_should_not_require_at_sign
    o = Object.new
    ivar_object = Metafun::Ivar::Ivar.new(o)
    ivar_object['x'] = 20
    assert_equal 20, ivar_object[:x]
  end
  
  def test_should_lazy_initialize_instance_variable
    o = Object.new
    ivar_object = Metafun::Ivar::Ivar.new(o)
    ivar_object['x'] = 10
    ivar_object['x'] ||= 20
    assert_equal 10, ivar_object[:x]
  end
  
  def test_should_allow_combined_assign_operators
    o = Object.new
    ivar_object = Metafun::Ivar::Ivar.new(o)
    ivar_object['x'] = 10
    ivar_object['x'] += 20
    assert_equal 30, ivar_object[:x]
  end
  
  def test_should_be_private
    o = Object.new
    assert o.private_methods.include?('ivar')
  end
end
