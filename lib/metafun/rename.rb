module Metafun
  module Rename
    module ClassMethods

    end

    module InstanceMethods
      def rename_method(old_name, new_name)
        alias_method new_name, old_name
        undef_method old_name
      end

      def rename_method!(old_name, new_name)
        alias_method new_name, old_name
        remove_method old_name
      end
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end

class Module
  include Metafun::Rename
end
