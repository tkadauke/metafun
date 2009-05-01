module CommonAnnotations
  module ClassMethods
    def set_definition_strategy(name, strategy)
      self.send(:"#{name}_definition_strategy=", strategy)
    end
    
    def definition_strategy(name)
      self.send(:"#{name}_definition_strategy")
    end
    
  protected
    def find_annotation_caller
      caller.find {|x|x !~ /(#{Regexp.escape(File.dirname(__FILE__))})/}
    end
  end
end
