require 'rubygems'
require 'activesupport'

require File.dirname(__FILE__) + '/selfclass'

module Metafun
  module Aliasing
    module ClassMethods
      def before_method(method_name, token = nil, &block)
        token ||= rand(100000)
        define_method "#{method_name}_with_#{token}" do |*args|
          raise ArgumentError, "wrong number of arguments (#{args.size} for #{arity})" if args.size != self.method("#{method_name}_without_#{token}").arity
          block.bind(self).call(*args)
          send("#{method_name}_without_#{token}", *args)
        end
      
        alias_method_chain method_name, token
      end
    
      def after_method(method_name, token = nil, &block)
        token ||= rand(100000)
        define_method "#{method_name}_with_#{token}" do |*args|
          raise ArgumentError, "wrong number of arguments (#{args.size} for #{arity})" if args.size != self.method("#{method_name}_without_#{token}").arity
          send("#{method_name}_without_#{token}", *args)
          block.bind(self).call(*args)
        end
      
        alias_method_chain method_name, token
      end
    
      def around_method(method_name, token = nil, &block)
        token ||= rand(100000)
        define_method "#{method_name}_with_#{token}" do |*args|
          raise ArgumentError, "wrong number of arguments (#{args.size} for #{arity})" if args.size != self.method("#{method_name}_without_#{token}").arity
          method_name_block = lambda do |*args|
            send("#{method_name}_without_#{token}", *args)
          end
        
          block.bind(self).call(*([method_name_block] + args))
        end
      
        alias_method_chain method_name, token
      end
    end
  
    def self.included(receiver)
      receiver.extend         ClassMethods
    end
  end
end

class Object
  include Metafun::Aliasing
end
