require 'rubygems'
require 'activesupport'

require File.dirname(__FILE__) + '/eigenclass'
require File.dirname(__FILE__) + '/common_annotations'

module ClassAnnotations
  module ClassMethods
    include CommonAnnotations::ClassMethods
    
    def define_class_annotation(*names)
      names.each do |name|
        class_inheritable_accessor :"#{name}_definition_strategy"
        set_definition_strategy(name, :swallow)
        cattr_accessor :"#{name}_collection"
        self.send(:"#{name}_collection=", [])

        ClassMethods.define_annotation(self, name)
      end
    end
    
    def self.define_annotation(base, name)
      base.eigenclass.send :define_method, name do |message|
        annotate_class(name, message)
      end
    end
    
  protected
    def annotate_class(name, message)
      send("#{self.definition_strategy(name)}_class_annotation_strategy", name, message)
    end

    def swallow_class_annotation_strategy(name, message)
      # do nothing
    end
    
    def collect_class_annotation_strategy(name, message)
      self.send(:"#{name}_collection") << {
        :message => message,
        :class => self,
        :caller => find_annotation_caller
      }
    end
    
    def report_class_annotation_strategy(name, message)
      STDERR.puts build_message_for_class_annotation(name, message)
    end
    
    def fail_class_annotation_strategy(name, message)
      raise build_message_for_class_annotation(name, message)
    end
    
    def build_message_for_class_annotation(name, message)
      "#{name.to_s.upcase}: #{message} (in #{self}, #{find_annotation_caller})"
    end
  end
  
  module InstanceMethods
  end
  
  def self.included(base)
    base.extend ClassMethods
    base.send :include, InstanceMethods
  end
end

if __FILE__ == $0
  class Object
    include ClassAnnotations
  
    define_class_annotation :todo
    self.todo_definition_strategy = :report
    
    todo 'something'
  end
  
  class Something
    todo 'oeoeoe?'
  end
end
