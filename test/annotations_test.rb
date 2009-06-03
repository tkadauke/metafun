require "test/unit"
require "rubygems"
require "mocha"

require File.dirname(__FILE__) + '/../lib/metafun/annotations'

class AnnotationsTest < Test::Unit::TestCase
  def setup
    Object.send :remove_const, :TestClass if Object.const_defined?(:TestClass)
    Object.send :const_set, :TestClass, Class.new
  end
  
  def test_should_define_simple_annotation
    TestClass.class_eval do
      define_annotation :log do |method|
        log_definition
      end
    end
    
    TestClass.expects(:log_definition)
    
    TestClass.class_eval do
      log
      def some_method
      end
    end
  end
  
  def test_should_define_more_complex_annotation
    TestClass.class_eval do
      define_annotation :remove do |method|
        remove_method method
      end
    end
    
    TestClass.class_eval do
      remove
      def some_method
      end
    end
    
    assert_raise NoMethodError do
      TestClass.new.some_method
    end
  end
  
  def test_should_define_complex_annotation
    TestClass.class_eval do
      define_annotation :decorate do |method|
        before_definition
        around_method method do |block, *args|
          before_call
          block.call(*args)
          after_call
        end
        after_definition
      end
    end
    
    TestClass.expects(:before_definition)
    TestClass.expects(:after_definition)
    
    TestClass.class_eval do
      decorate
      def some_method
        in_call
      end
    end
    
    t = TestClass.new
    t.expects(:before_call)
    t.expects(:in_call)
    t.expects(:after_call)
    t.some_method
  end
  
  def test_should_annotate_single_method
    define_class
    
    TestClass.expects(:log_definition).with(:some_method, 'message')
    TestClass.class_eval do
      log 'message'
      def some_method
      end
      
      def something_else
      end
    end
  end
  
  def test_should_annotate_singleton_method
    define_class
    
    TestClass.expects(:log_definition).with(:some_method, 'message')
    TestClass.class_eval do
      log 'message'
      def self.some_method
      end
      
      def self.something_else
      end
    end
  end
  
  def test_should_annotate_multiple_methods
    define_class
    
    TestClass.expects(:log_definition).with(:some_method, 'message')
    TestClass.expects(:log_definition).with(:some_other_method, 'message')
    TestClass.class_eval do
      log 'message' do
        def some_method
        end
        
        def some_other_method
        end
      end
      
      def something_else
      end
    end
  end

  def test_should_annotate_multiple_singleton_methods
    define_class
    
    TestClass.expects(:log_definition).with(:some_method, 'message')
    TestClass.expects(:log_definition).with(:some_other_method, 'message')
    TestClass.class_eval do
      log 'message' do
        def self.some_method
        end
      
        def self.some_other_method
        end
      end
      
      def self.something_else
      end
    end
  end
  
  
  def test_should_nest_annotations
    define_class
    
    TestClass.expects(:log_definition).with(:some_method, 'message')
    TestClass.expects(:log_definition).with(:some_other_method, 'message')
    TestClass.expects(:log_definition).with(:something_else, 'message')
    TestClass.expects(:log_more_definition).with(:some_method)
    TestClass.expects(:log_more_definition).with(:some_other_method)
    
    TestClass.class_eval do
      log 'message' do
        log_more
        def some_method
        end
        
        log_more do
          def some_other_method
          end
        end
        
        def something_else
        end
      end
    end
  end
  
protected
  def define_class
    TestClass.class_eval do
      define_annotation :log do |method, message|
        log_definition method, message
      end
      
      define_annotation :log_more do |method|
        log_more_definition method
      end
    end
  end
end
