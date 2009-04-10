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
        @parent = nil
      end

      def to_s
        add_root!

        @parent = @doc.root

        dump(@target)

        @doc.to_xml
      end

      def to_o
        @doc = Nokogiri::XML(@target, nil, nil, PARSE_NOBLANKS)
        @doc.root.children.each do |child|
          return true if child['class']   == 'TrueClass'
          return false if child['class']  == 'FalseClass'
          return nil if child['class']    == 'NilClass'
          return Integer(child.content) if child['class'] == 'Fixnum'
          return Float(child.content) if child['class'] == 'Float'
          return child.content.to_sym if child['class'] == 'Symbol'
        end
      end

      private
      def x_dump target
        div = @parent.add_child(Node.new('div', @doc))
        div['class'] = @target.class.name

        span = div.add_child(Node.new('span', @doc))
        case type = target_type
        when :true, :false, :nil
          span.add_child(Text.new(type.to_s, @doc))
        when :fixnum, :float
          span.add_child(Text.new(@target.to_s, @doc))
        end
      end

      def push node_name
        @parent = @parent.add_child(Node.new(node_name, @doc))
      end

      def pop
        @parent = @parent.parent
      end

      ###
      # Add some text to the current parent node
      def text text
        @parent.add_child(Text.new(text, @doc))
      end

      def add_root!
        @doc.root = Element.new('marshal', @doc)
      end
    end
  end
end
