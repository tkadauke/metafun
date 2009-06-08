require 'rubygems'
require 'activesupport'

require File.dirname(__FILE__) + '/selfclass'

module Metafun
  module Aliasing
    module InstanceMethods
      def before_method(method_name, token = nil, &block)
        token ||= rand(100000)
        define_method "#{method_name}_with_#{token}" do |*args|
          arity = self.method("#{method_name}_without_#{token}").arity
          raise ArgumentError, "wrong number of arguments (#{args.size} for #{arity})" if args.size != arity
          block.bind(self).call(*args)
          send("#{method_name}_without_#{token}", *args)
        end
      
        alias_method_chain method_name, token
      end
    
      def after_method(method_name, token = nil, &block)
        token ||= rand(100000)
        define_method "#{method_name}_with_#{token}" do |*args|
          arity = self.method("#{method_name}_without_#{token}").arity
          raise ArgumentError, "wrong number of arguments (#{args.size} for #{arity})" if args.size != arity
          send("#{method_name}_without_#{token}", *args)
          block.bind(self).call(*args)
        end
      
        alias_method_chain method_name, token
      end
    
      def around_method(method_name, token = nil, &block)
        token ||= rand(100000)
        define_method "#{method_name}_with_#{token}" do |*args|
          arity = self.method("#{method_name}_without_#{token}").arity
          raise ArgumentError, "wrong number of arguments (#{args.size} for #{arity})" if args.size != arity
          method_name_block = lambda do |*args|
            send("#{method_name}_without_#{token}", *args)
          end
        
          block.bind(self).call(*([method_name_block] + args))
        end
      
        alias_method_chain method_name, token
      end
    end
  
    def self.included(receiver)
      receiver.send :include, InstanceMethods
    end
  end
end

class Module
  include Metafun::Aliasing
end
