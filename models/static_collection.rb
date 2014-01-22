class StaticCollection
  class Item
    def self.name
      @name
    end
    def self.id
      @id
    end
    def self.eql?(other_item)
      other_item.superclass.__id__ == self.superclass.__id__ and other_item.id == self.id
    end
    def self.==(other_item)
      self.eql? other_item
    end
    def self.hash
      (self.superclass.hash + (@id||0))
    end
  end

  KNOWN_ATTRIBUTE_TYPES = %w{string symbol number boolean custom}.map &:to_sym
  module ClassMethods
    def clear
      @attributes = []
      @items = []
      @max_id = 0
      @item_class = Class.new(StaticCollection::Item)
      unless self == StaticCollection
        self.const_set("ItemMethods".to_sym, Module.new)
        @item_class.send :extend, self::ItemMethods
      end
    end

    def item_class
      @item_class
    end

    def attribute(name, attribute_type=:string)
      raise Error::WrongAttributeType.new(name, attribute_type) unless StaticCollection::KNOWN_ATTRIBUTE_TYPES.include?(attribute_type)
      attribute = Attribute.new(name, attribute_type)
      @attributes << attribute
      (class << item_class; self; end).instance_eval do
        define_method name do
          self.instance_variable_get("@#{attribute.name}")
        end
      end
    end

    def attributes
      @attributes
    end

    def item(name, options={})
      raise Error::WrongNumberOfAttributes.new(self) unless (name.is_a?(Symbol) and options.is_a?(Hash))
      options.symbolize_keys!
      item_class_name = name.to_s.classify
      if self.all.compact.map{|t| t.name.to_s.classify}.include?(name.to_s.classify)
        raise Error::NameTaken.new(item_class_name, self)
      end
      item = const_set item_class_name, Class.new(item_class)
      item.instance_variable_set("@name", name)
      if options.has_key?(:id)
        raise Error::WrongIDFormat.new(self) unless (options[:id].is_a?(Integer) and options[:id] > 0)
        id = options.delete(:id)
      else
        id = @max_id + 1
        while self.find(id)
          id += 1
        end
        @max_id = id
      end
      if self.find(id)
        raise Error::IDTaken.new(id,self)
      end
      item.instance_variable_set("@id", id)
      options.each do |key,val|
        attribute = @attributes.find {|a| a.name == key}
        unless attribute
          raise Error::UnknownAttribute.new(key, self)
        end
        item.instance_variable_set("@#{key}", attribute.convert(val))
      end
      @items[id-1] = item
    end

    def all
      @items
    end

    def fields_for_select
      self.all.collect{|x| [x.title, x.id]}
    end

    def find_by_name(name)
      self.all.find{|x| x.name == name.to_s.downcase.tr(' ', '_').to_sym}
    end

    def find(id)
      id = id.to_i
      if id > 0 and id <= @items.count
        @items[id - 1]
      else
        nil
      end
    end
  end
  self.extend ClassMethods
  self.clear
  def self.inherited(klass)
    klass.clear
  end

  module Error
    class Base < Exception
      def message; @message; end
    end
    class WrongAttributeType < Base
      def initialize(attr_name, attr_type)
        super()
        @message = "StaticCollection attribute #{attr_name.inspect} has wrong (not implemented) type: #{attr_type}.\nKnown attribute types: #{StaticCollection::KNOWN_ATTRIBUTE_TYPES.map(&:inspect).join(', ')}"
      end
    end
    class WrongNumberOfAttributes < Base
      def initialize(klass)
        super()
        @message = "StaticCollection #{klass.name}.item takes a name and an option hash"
      end
    end


    class UnknownAttribute < Base
      def initialize(attr_name, klass)
        super()
        @message = "Unknown attribute #{attr_name.inspect} for #{klass.name}"
      end
    end

    class WrongIDFormat < Base
      def initialize(klass)
        super()
        @message = "#{klass.name} id must be of type Integer"
      end
    end

    class IDTaken < Base
      def initialize(id, klass)
        super()
        @message = "#{klass.name} id #{id} has already been taken"
      end
    end

    class NameTaken < Base
      def initialize(name, klass)
        super()
        @message = "#{klass.name} item name #{name} has already been taken"
      end
    end
  end

  class Attribute
    attr_reader :attribute_type, :name
    def initialize(name, attribute_type)
      @name = name
      @attribute_type = attribute_type
    end

    def convert(val)
      case @attribute_type
        when :string 
          val.to_s
        when :symbol 
          val.to_sym
        when :number 
          val.to_i
        when :boolean 
          val ? true : false
        when :custom
          val
      end
    end
  end

end
