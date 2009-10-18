module Wank
  module XML
    class Emitter
      attr_accessor :documents

      SCALAR_TAG   = 'p'
      SCALAR_TAGS  = %w{ p li dt dd }
      SEQUENCE_TAG = 'ol'
      MAPPING_TAG  = 'dl'

      def initialize
        @documents = []
        @stack     = []
      end

      def start_stream encoding
      end

      def start_document version, directives, implicit
        doc = Nokogiri::XML::Document.new
        doc.encoding = 'UTF-8'
        @stack.push doc
      end

      def start_sequence anchor, tag, implicit, style
        node = Nokogiri::XML::Node.new(SEQUENCE_TAG, @stack.last.document)
        add_child node
        @stack.push node
      end

      def end_sequence
        @stack.pop
      end

      def start_mapping anchor, tag, implicit, style
        node = Nokogiri::XML::Node.new(MAPPING_TAG, @stack.last.document)
        add_child node
        @stack.push node
      end

      def end_mapping
        @stack.pop
      end

      def scalar value, anchor, tag, plain, quoted, style
        text = Nokogiri::XML::Text.new(value, @stack.last.document)

        if root?
          tag = Nokogiri::XML::Node.new(SCALAR_TAG, @stack.last.document)
          add_child tag
          @stack.push tag
        end

        add_child text
      end

      def end_document implicit
        @documents << @stack.pop
      end

      def end_stream
      end

      private
      def root?
        @stack.last == @stack.last.document
      end

      def add_child node
        target = @stack.last
        if target.name == SEQUENCE_TAG
          target = Nokogiri::XML::Node.new('li', @stack.last.document)
          @stack.last.add_child target
        end

        if target.name == MAPPING_TAG
          name = (target.children.length % 2) == 0 ? 'dt' : 'dd'
          target = Nokogiri::XML::Node.new(name, @stack.last.document)
          @stack.last.add_child target
        end

        target.add_child node
      end
    end
  end
end
