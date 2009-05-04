module Metafun
  module Eigenclass
    def eigenclass
      (class << self; self; end)
    end
  end
end

Object.send :include, Metafun::Eigenclass
