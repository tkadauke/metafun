require File.dirname(__FILE__) + '/annotations'
require File.dirname(__FILE__) + '/selfclass'

module Metafun
  module AutoAnnotations
    module Strategies
      def swallow_method_annotation_strategy(name, message, method_name)
        # do nothing
      end

      def collect_method_annotation_strategy(name, message, method_name)
        @method_annotation_collections ||= {}
        @method_annotation_collections[name] ||= []
        
        @method_annotation_collections[name] << {
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

    protected
      def find_annotation_caller
        caller.find {|x|x !~ /(#{Regexp.escape(File.dirname(__FILE__))})/}
      end
    end
    
    module ClassMethods
      def define_auto_annotation(name, options = {})
        define_annotation name do |method, message|
          selfclass.send("#{options[:definition]}_method_annotation_strategy", name, message, method) if options[:definition]
          before_method method do
            selfclass.send("#{options[:execution]}_method_annotation_strategy", name, message, method) if options[:execution]
          end
        end
      end
    end
  
    module InstanceMethods
    
    end
  
    def self.included(receiver)
      receiver.extend         Strategies
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end

class Object
  include Metafun::Aliasing
  include Metafun::Annotations
  include Metafun::AutoAnnotations
  
  define_auto_annotation :fucko, :definition => :report, :execution => :fail
  
  fucko 'ugly'
  def hello
    puts "this sucks"
  end
end

Object.new.hello
