module NoBrainer::Document::Aliases
  extend ActiveSupport::Concern

  # Index aliases are built-in index.rb

  included do
    # We ignore polymorphism for aliases.
    cattr_accessor :alias_map, :alias_reverse_map, :instance_accessor => false
    self.alias_map = {}
    self.alias_reverse_map = {}
  end

  def assign_attributes(attrs, options={})
    if options[:from_db]
      attrs = Hash[attrs.map { |k,v| [self.class.reverse_lookup_field_alias(k), v] }]
    end
    super(attrs, options)
  end

  module ClassMethods
    def _field(attr, options={})
      if options[:as]
        self.alias_map[attr.to_s] = options[:as].to_s
        self.alias_reverse_map[options[:as].to_s] = attr.to_s
      end
      super
    end

    def _remove_field(attr, options={})
      super

      self.alias_map.delete(attr.to_s)
      self.alias_reverse_map.delete(attr.to_s)
    end

    def reverse_lookup_field_alias(attr)
      alias_reverse_map[attr.to_s] || attr
    end

    def lookup_field_alias(attr)
      alias_map[attr.to_s] || attr
    end

    def persistable_key(k)
      lookup_field_alias(super)
    end
  end
end
