require "test/unit"
require "rubygems"
require "mocha"

require File.dirname(__FILE__) + '/../lib/metafun/aliasing'

class AliasingTest < Test::Unit::TestCase
  def setup
    Object.send :remove_const, :TestClass if Object.const_defined?(:TestClass)
    Object.send :const_set, :TestClass, Class.new
    
    TestClass.class_eval do
      def foo
        some_method
      end
      
      def bar(num)
        some_method(num)
      end
    end
  end
  
  def test_should_prepend_block_to_method
    TestClass.class_eval do
      before_method :foo do
        some_other_method
      end
    end
    
    obj = TestClass.new
    obj.expects(:some_method)
    obj.expects(:some_other_method)
    obj.foo
  end
  
  def test_should_append_block_to_method
    TestClass.class_eval do
      after_method :foo do
        some_other_method
      end
    end
    
    obj = TestClass.new
    obj.expects(:some_method)
    obj.expects(:some_other_method)
    obj.foo
  end
  
  def test_should_wrap_block_around_method
    TestClass.class_eval do
      around_method :foo do |block|
        some_before_method
        block.call
        some_after_method
      end
    end

    obj = TestClass.new
    obj.expects(:some_method)
    obj.expects(:some_before_method)
    obj.expects(:some_after_method)
    obj.foo
  end
  
  def test_should_raise_argument_error_if_arity_incorrect
    TestClass.class_eval do
      before_method :bar do |num|
        some_other_method(num)
      end
    end

    obj = TestClass.new
    obj.expects(:some_method).with(10)
    obj.expects(:some_other_method).with(10)
    obj.bar(10)
  end
  
  def test_should_use_token_if_supplied
    TestClass.class_eval do
      before_method :bar, :something do |num|
        some_other_method(num)
      end
    end
    assert TestClass.new.methods.include?('bar_with_something')
  end
end
