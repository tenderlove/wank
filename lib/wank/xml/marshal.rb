module Wank
  module XML
    class Marshal
      include Nokogiri::XML

      def self.dump object
        new(object).to_s
      end

      def self.load object
        new(object).to_o
      end

      def initialize target
        @target = target
        @doc    = Nokogiri::XML::Document.new
      end

      def to_s
        add_root!
        case type = target_type
        when :true, :false, :nil
          span = @doc.root.add_child(Node.new('span', @doc))
          span['class'] = @target.class.name
          span.add_child(Text.new(type.to_s, @doc))
        when :fixnum
          span = @doc.root.add_child(Node.new('span', @doc))
          span['class'] = @target.class.name
          span.add_child(Text.new(@target.to_s, @doc))
        end
        @doc.to_xml
      end

      def to_o
        @doc = Nokogiri::XML(@target, nil, nil, PARSE_NOBLANKS)
        @doc.root.children.each do |child|
          return true if child['class'] == 'TrueClass'
          return false if child['class'] == 'FalseClass'
          return nil if child['class'] == 'NilClass'
          return Integer(child.content) if child['class'] == 'Fixnum'
        end
      end

      private
      def dump target
      end

      def add_root!
        @doc.root = Element.new('marshal', @doc)
      end
    end
  end
end
