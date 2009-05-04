module Metafun
  module Eigenclass
    def eigenclass
      (class << self; self; end)
    end
  end
end

class Object
  include Metafun::Eigenclass
end
