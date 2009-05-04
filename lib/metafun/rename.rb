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
