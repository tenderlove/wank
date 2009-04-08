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
        case target_type
        when :true
          span = @doc.root.add_child(Node.new('span', @doc))
          span['class'] = @target.class.name
          span.add_child(Text.new('true', @doc))
        end
        @doc.to_xml
      end

      def to_o
        @doc = Nokogiri::XML(@target, nil, nil, PARSE_NOBLANKS)
        true
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
