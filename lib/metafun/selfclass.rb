module Metafun
  module Selfclass
    module ClassMethods
      def selfclass
        self
      end
    end
  
    module InstanceMethods
      def selfclass
        self.class
      end
    end
  
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end

class Object
  include Metafun::Selfclass
end
