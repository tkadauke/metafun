require File.dirname(__FILE__) + '/aliasing'
require File.dirname(__FILE__) + '/eigenclass'

module Metafun
  module Annotations
    module ClassMethods
      def define_annotation(name, &block)
        self.class_eval %{
          def self.#{name}(*params, &block)
            puts "annot: #{name}"
            annotate_method(:#{name}, params, &block)
          end
        }, __FILE__
      
        self.eigenclass.send :define_method, :"method_added_with_#{name}" do |method_name|
          return if @aliasing
          method_added_with_annotation(name, method_name, &block)
          send(:"method_added_without_#{name}", method_name)
        end
      
        self.eigenclass.send :alias_method_chain, :method_added, name

        self.eigenclass.send :define_method, :"singleton_method_added_with_#{name}" do |method_name|
          return if @aliasing
          singleton_method_added_with_annotation(name, method_name, &block)
          send(:"singleton_method_added_without_#{name}", method_name)
        end

        self.eigenclass.send :alias_method_chain, :singleton_method_added, name
      end
    
    protected
      def set_annotation_params(name, params)
        @method_annotation_params ||= {}
        @method_annotation_params[name] = params
      end
    
      def clear_annotation_params(name)
        @method_annotation_params ||= {}
        @method_annotation_params[name] = nil
      end
    
      def annotation_params(name)
        @method_annotation_params[name] if @method_annotation_params
      end
    
      def enter_annotation_stack(name, params)
        set_annotation_params(name, params)
        @method_annotation_stack ||= {}
        @method_annotation_stack[name] ||= []
        @method_annotation_stack[name] << params
      end
    
      def leave_annotation_stack(name)
        @method_annotation_stack[name].pop
        @method_annotation_params[name] = @method_annotation_stack[name].last
      end

      def annotate_method(name, params, &block)
        @method_annotation_params ||= {}
        @method_annotation_stack ||= {}
        @method_annotation_stack[name] ||= []

        if block_given?
          begin
            enter_annotation_stack(name, params)
            yield
          ensure
            leave_annotation_stack(name)
          end
        else
          set_annotation_params(name, params)
        end
      end

      def method_added_with_annotation(name, method_name, &block)
        params = annotation_params(name)
        unless params.nil?
          clear_annotation_params(name) if @method_annotation_stack[name].blank?
          @aliasing = true
          block.call(method_name, *params)
          @aliasing = false
        end
      end
    
      def singleton_method_added_with_annotation(name, method_name, &block)
        params = annotation_params(name)
        unless params.nil?
          clear_annotation_params(name) if @method_annotation_stack[name].blank?
          @aliasing = true
          block.call(method_name, *params)
          @aliasing = false
        end
      end
    end
  
    module InstanceMethods
    
    end
  
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end

class Object
  include Metafun::Annotations
end

if __FILE__ == $0
  class Object
    include Metafun::Aliasing
    include Metafun::Annotations
  
    define_annotation :logged do |method, message, expiry|
      p message
      around_method method do |block, *args|
        puts "entering #{method}: #{message} (#{expiry})"
        result = block.call(*args)
        puts "exiting #{method}: #{message} (#{expiry})"
        result
      end
    end
  
    logged "this is a log", 10 do
      def hello
        puts "yeah"
      end
  
      def world
        puts "foo"
      end
    end
    
    define_annotation :dont do |method|
      puts "removing #{method}"
      remove_method method
    end
    
    dont
    def whaddup
      puts "whaddup"
    end
    
    def yeah
      puts "yo"
    end
  end

  o = Object.new
  o.hello
  o.world
  o.yeah
  o.whaddup
end
