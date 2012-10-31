require File.dirname(__FILE__) + '/eigenclass'

module Metafun
  module Hierarchy
    module ClassAdditions
      module InstanceMethods
        def class_hierarchy
          self.ancestors.select { |cls| cls.class == Class }
        end
        
        def superclasses
          class_hierarchy[1..-1]
        end
        
        def eigenclass_hierarchy
          class_hierarchy.collect { |cls| cls.eigenclass }
        end

        def supereigenclasses
          eigenclass_hierarchy[1..-1]
        end
      end
      
      def self.included(base)
        base.send :include, InstanceMethods
      end
    end
    
    module ObjectAdditions
      module InstanceMethods
        def extended_modules
          eigenclass.ancestors.select { |mod| mod.class == Module }
        end

        def usable_modules
          (self.extended_modules + self.class.included_modules)
        end
      end
      
      def self.included(base)
        base.send :include, InstanceMethods
      end
    end
  end
end

class Class
  include Metafun::Hierarchy::ClassAdditions
end

class Object
  include Metafun::Hierarchy::ObjectAdditions
end
