require "test/unit"

require File.dirname(__FILE__) + '/../lib/metafun/rename'

class RenameTest < Test::Unit::TestCase
  def setup
    Object.send :remove_const, :TestClass if Object.const_defined?(:TestClass)
    Object.send :const_set, :TestClass, Class.new
    TestClass.class_eval do
      def foo
        some_method
      end
    end
  end
  
  def test_should_rename_method
    assert   TestClass.instance_methods.include?('foo')
    assert ! TestClass.instance_methods.include?('bar')
    TestClass.rename_method :foo, :bar
    assert ! TestClass.instance_methods.include?('foo')
    assert   TestClass.instance_methods.include?('bar')
  end
  
  def test_should_hard_rename_method
    assert   TestClass.instance_methods.include?('foo')
    assert ! TestClass.instance_methods.include?('bar')
    TestClass.rename_method! :foo, :bar
    assert ! TestClass.instance_methods.include?('foo')
    assert   TestClass.instance_methods.include?('bar')
  end

  def test_should_not_crash_if_renaming_internally_protected_method
    assert   TestClass.instance_methods.include?('inspect')
    assert ! TestClass.instance_methods.include?('instecp')
    assert_nothing_raised do
      TestClass.rename_method :inspect, :instecp
    end
    assert ! TestClass.instance_methods.include?('inspect')
    assert   TestClass.instance_methods.include?('instecp')
  end
  
  def test_should_crash_if_hard_renaming_internally_protected_method
    assert   TestClass.instance_methods.include?('inspect')
    assert ! TestClass.instance_methods.include?('instecp')
    assert_raise NameError do
      TestClass.rename_method! :inspect, :instecp
    end
    assert   TestClass.instance_methods.include?('inspect') # still there
    assert   TestClass.instance_methods.include?('instecp')
  end
end
