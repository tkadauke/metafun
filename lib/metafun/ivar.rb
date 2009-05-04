module Metafun
  module Ivar
    class Ivar
      def initialize(object)
        @object = object
      end
    
      def [](var)
        @object.instance_variable_get(add_at_sign(var))
      end
    
      def []=(var, value)
        @object.instance_variable_set(add_at_sign(var), value)
      end
    
    private
      def add_at_sign(sym)
        case sym.to_s
        when /^@/ then sym
        else
          :"@#{sym}"
        end
      end
    end

  private
    def ivar
      Ivar.new(self)
    end
  end
end

Object.send :include, Metafun::Ivar
