# metafun

Copyright (c) 2008 Thomas Kadauke

This gem is a collection of some metaprogramming techniques that I experimented with over time. The different modules are:

## aliasing

This module allows for some simple aspect oriented programming in Ruby. It offers an easy way to extend methods by adding code before, after or around them, similar to before, after and around filters in Rails.

Example:

    class Dog
      def bark
        puts "Woof!"
      end
      
      after_method :bark do
        puts "Bark!"
      end
    end
    
    d = Dog.new
    d.bark # => outputs Woof! and Bark!

## eigenclass

This simple module adds the method "eigenclass" to Object.

## hierarchy

This module adds support for inspecting the class hierarchy of a class.

The following methods are added to Class

    class_hierarchy # => returns all ancestors of type Class
    superclasses # => returns all ancestors of type Class excluding the current class
    eigenclass_hierarchy # => returns all ancestors' eigenclasses
    supereigenclasses # => returns all ancestors' eigenclasses excluding the current class'

These methods are added to Object

    extended_modules # => returns all ancestors of type Module
    usable_modules # => returns extended and included modules

## ivar

This module defines a nice interface for accessing instance variables with dynamic names. It wraps around the instance_variable_get and instance_variable_set methods. It defines the private ivar method, that allows access to the current object's instance variables over a hash-like interface. Example:

    class Rect
      attr_accessor :width, :height
      def twice(dimension)
        ivar[dimension] * 2
      end
      
      def set_dimension(dimension, size)
        ivar[dimension] = size
      end
    end
    
    r = Rect.new
    r.set_dimension(:width, 10)
    r.twice(:width) # => 20

## rename

This adds the method "rename_method" to classes and modules.

## selfclass

This module adds a shortcut for getting the class object from an object. For classes, it returns self. For objects, it returns the class object.