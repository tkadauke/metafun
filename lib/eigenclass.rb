module Eigenclass
  def eigenclass
    (class << self; self; end)
  end
end

Object.send :include, Eigenclass
