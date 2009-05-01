require 'rubygems'
require 'activesupport'

require File.dirname(__FILE__) + '/eigenclass'
require File.dirname(__FILE__) + '/common_annotations'

module MethodAnnotations
  module ClassMethods
    include CommonAnnotations::ClassMethods
    
    def define_method_annotation(*names)
      names.each do |name|
        class_inheritable_accessor :"#{name}_definition_strategy"
        set_definition_strategy(name, :swallow)
        class_inheritable_accessor :"#{name}_execution_strategy"
        set_execution_strategy(name, :swallow)
        cattr_accessor :"#{name}_collection"
        self.send(:"#{name}_collection=", [])

        ClassMethods.define_annotation(self, name)
        InstanceMethods.define_annotation(self, name)

        [:method_added, :singleton_method_added].each do |hook|
          begin
            eigenclass.send :alias_method_chain, hook, name
          rescue
            eigenclass.send :alias_method, hook, :"#{hook}_with_#{name}"
          end
        end
      end
    end
    
    def self.define_annotation(base, name)
      base.class_eval %{
        def self.#{name}(message = "", &block)
          annotate_method(:#{name}, message, &block)
        end
      }, __FILE__
      
      base.eigenclass.send :define_method, :"method_added_with_#{name}" do |method_name|
        return if @aliasing
        method_added_with_annotation(name, method_name)
        send(:"method_added_without_#{name}", method_name)
      end

      base.eigenclass.send :define_method, :"singleton_method_added_with_#{name}" do |method_name|
        return if @aliasing
        singleton_method_added_with_annotation(name, method_name)
        send(:"singleton_method_added_without_#{name}", method_name)
      end
    end
    
    def set_execution_strategy(name, strategy)
      self.send(:"#{name}_execution_strategy=", strategy)
    end
    
    def execution_strategy(name)
      self.send(:"#{name}_execution_strategy")
    end
    
  protected
    def annotate_method(name, message, &block)
      @method_annotations ||= {}
      @method_annotation_stack ||= {}
      @method_annotation_stack[name] ||= []

      if block_given?
        begin
          enter_annotation_stack(name, message)
          yield
        ensure
          leave_annotation_stack(name)
        end
      else
        set_annotation_message(name, message)
      end
    end
    
    def method_added_with_annotation(name, method_name)
      message = annotation_message(name)

      if message
        @method_annotations[name] = nil if @method_annotation_stack[name].blank?

        @aliasing = true
        send("#{self.definition_strategy(name)}_method_annotation_strategy", name, message, method_name)
        original_method = :"#{method_name}_without_#{name}"
        alias_method original_method, method_name

        define_method(method_name) do |*args|
          self.class.send("#{self.class.execution_strategy(name)}_method_annotation_strategy", name, message, method_name)
          send(original_method)
        end
        @aliasing = false
      end
    end
    
    def singleton_method_added_with_annotation(name, method_name)
      message = annotation_message(name)

      if message
        @method_annotations[name] = nil if @method_annotation_stack[name].blank?

        @aliasing = true
        send("#{self.definition_strategy(name)}_method_annotation_strategy", name, message, method_name)
        original_method = :"#{method_name}_without_#{name}"
        eigenclass.send :alias_method, original_method, method_name

        eigenclass.send(:define_method, method_name) do |*args|
          self.send("#{self.execution_strategy(name)}_method_annotation_strategy", name, message, method_name)
          send(original_method)
        end
        @aliasing = false
      end
    end
    
    def set_annotation_message(name, message)
      @method_annotations ||= {}
      @method_annotations[name] = message
    end
    
    def annotation_message(name)
      @method_annotations[name] if @method_annotations
    end
    
    def enter_annotation_stack(name, message)
      set_annotation_message(name, message)
      @method_annotation_stack ||= {}
      @method_annotation_stack[name] ||= []
      @method_annotation_stack[name] << message
    end
    
    def leave_annotation_stack(name)
      @method_annotation_stack[name].pop
      @method_annotations[name] = @method_annotation_stack[name].last
    end
    
    def swallow_method_annotation_strategy(name, message, method_name)
      # do nothing
    end
    
    def collect_method_annotation_strategy(name, message, method_name)
      self.send(:"#{name}_collection") << {
        :message => message,
        :method_name => method_name,
        :caller => find_annotation_caller
      }
    end
    
    def report_method_annotation_strategy(name, message, method_name)
      STDERR.puts build_message_for_method_annotation(name, message, method_name)
    end
    
    def fail_method_annotation_strategy(name, message, method_name)
      raise build_message_for_method_annotation(name, message, method_name)
    end
    
    def build_message_for_method_annotation(name, message, method_name)
      "#{name.to_s.upcase}: #{message} (method '#{self.name}##{method_name}' in #{find_annotation_caller})"
    end
  end
  
  module InstanceMethods
    def self.define_annotation(base, name)
      base.send :define_method, name do |message|
        caller[2] =~ /`(.*)'/
        self.class.send("#{self.class.execution_strategy(name)}_method_annotation_strategy", name, message, $1)
      end
    end
  end
  
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end
end

if __FILE__ == $0
  class Object
    include MethodAnnotations
  
    define_method_annotation :fucko, :tempo, :todo, :removeme, :aufsplitto
    self.aufsplitto_definition_strategy = :collect
    self.fucko_definition_strategy = :report
    self.fucko_execution_strategy = :report
  end

  class Ass
  end

  class Shit < Ass
  end

  class Ass
    fucko "shit"
    def a
    end
  end

  class Osluch
    define_method_annotation :smell
    self.smell_definition_strategy = :report
  
    smell 'disgusting'
    def fuck
    end
  end

  class Shit < Ass
    fucko "shi"
    def fuckoed?
      fucko 'remove this shit'
      todo 'get outta here'
    end
  
    aufsplitto 'this is shit'
    fucko "pi" do
      def fuckoed_in_block
      end
    end
  
    fucko 'singleton' do
      def self.singleton
      end
    end
  
    def unfuckoed
    end
  
    class Inner
      fucko 'inner class' do
        def oeoeoe
        end
      end
    end
  
    removeme "asap" do
      fucko "fnarf" do
        def removemed_and_fuckoed
        end
      end
    
      def only_removemed
      end
    end
  end

  class Something
    fucko 'This method sucks'
    def sucking_method
    end
  end

  begin
    Shit.new.fuckoed?
    Shit.singleton
  rescue Exception => e
    puts e.message
    puts e.backtrace
  end
end
