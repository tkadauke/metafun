module Metafun
  module RenameMethod
    def rename_method(old_name, new_name)
      alias_method new_name, old_name
      undef_method old_name
    end

    def rename_method!(old_name, new_name)
      alias_method new_name, old_name
      remove_method old_name
    end
  end
end

Module.send :include, Metafun::RenameMethod

if __FILE__ == $0
  require File.dirname(__FILE__) + '/eigenclass'
  
  class Something
    def old_name
      puts 'hello'
    end
    
    def self.old_name
      puts 'singleton hello'
    end

    rename_method :old_name, :new_name
    rename_method! :inspect, :instecp rescue nil
    
    eigenclass.rename_method :old_name, :new_name
  end

  Something.new.new_name
  puts Something.new.inspect
  puts Something.new.instecp
  Something.new_name
end
