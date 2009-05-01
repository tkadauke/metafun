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
      sym = :"@#{sym}" unless sym.to_s =~ /^@/
    end
  end

private
  def ivar
    Ivar.new(self)
  end
end

Object.send :include, Ivar

if __FILE__ == $0
  class Something
    [:a, :b, :c].each do |x|
      define_method x do
        ivar[x] ||= 0
        ivar[x] += 1
      end
    end
  end

  s = Something.new
  puts s.a
  puts s.a
  puts s.a
end
