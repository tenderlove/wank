module Wank
  module XML
    class Emitter
      attr_accessor :document

      SCALAR_TAG   = 'p'
      SCALAR_TAGS  = %w{ p li dt dd }
      SEQUENCE_TAG = 'ol'
      MAPPING_TAG  = 'dl'

      def initialize
        @document = nil
        @stack    = []
      end

      def start_stream encoding
      end

      def start_document version, directives, implicit
        @document = Nokogiri::XML::Document.new
        @document.encoding = 'UTF-8'
        @stack.push @document
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
        node['class'] = tag.split(':', 2).join(' ') if tag
        add_child node
        @stack.push node
      end

      def end_mapping
        @stack.pop
      end

      def scalar value, anchor, tag, plain, quoted, style
        if root?
          tag = Nokogiri::XML::Node.new(SCALAR_TAG, @stack.last.document)
          tag.content = value
          add_child tag
        else
          text = Nokogiri::XML::Text.new(value, @stack.last.document)
          add_child text
        end
      end

      def end_document implicit
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
