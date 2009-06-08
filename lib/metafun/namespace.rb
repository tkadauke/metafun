require File.dirname(__FILE__) + '/ivar'
require File.dirname(__FILE__) + '/eigenclass'
require 'rubygems'
require 'activesupport'

module Metafun
  module Concern
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
    end
    
    module ClassMethods
      
    end
    
    module InstanceMethods
      def concern(name, &block)
        ivar[name] ||= begin
          klass = Class.new
          klass.class_eval do
            instance_methods.each { |m| undef_method m unless m =~ /^__/ || m == 'instance_eval' }
            
            def initialize(object)
              @object = object
            end
      
            def method_missing(method, *args, &block)
              if @object.respond_to?(method)
                @object.send(method, *args, &block)
              else
                super
              end
            end
            
            eigenclass.send :public, :include
          end
    
          define_method name do
            ivar[name] ||= klass.new(self)
          end
    
          eigenclass.send :define_method, name do
            klass
          end
    
          klass.eigenclass.send :define_method, :name do
            name.to_s
          end
      
          klass
        end
    
        ivar[name].class_eval &block
        class_eval do
          yield
        end
      end
    end
  end
end

class Module
  include Metafun::Concern
end

if __FILE__ == $0
  module Mod
    def oeoeoe
      puts 'oeoeoe'
    end
  end

  class Something
    def some_method
      thing.other_concerned_method
    end
  
    concern :thing do
      def concerned_method
        some_method
      end
    
      def self.concerned_singleton
        puts 'singleton'
      end
    
      def other_concerned_method
        puts "hello"
      end
    
      def add
        @num ||= 0
        @num += 1
      end
    
      concern :inner do
        def inner_method
          puts "inner"
        end
      end
    end
  
    concern :thing do
      def sub
        @num -= 1
      end
    end
  
    concern :another do
      include Mod
    end
  end

  Something.thing.concerned_singleton
  p Something.thing.name

  s = Something.new
  s.some_method
  s.thing.instance_eval do
    concerned_method
    inner.inner_method
  end
  s.thing.inner.inner_method
  puts s.thing.add
  puts s.thing.add
  puts s.thing.sub
  s.inner_method
  def s.inner_method
    puts 'bla'
  end
  s.inner_method
  s.thing.inner.inner_method
  s.another.oeoeoe
  puts "---"
  p s
end
