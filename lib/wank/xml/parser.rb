module Wank
  module XML
    class Parser < Nokogiri::XML::SAX::Document
      attr_reader :tree, :stack

      def initialize
        @tree  = Psych::TreeBuilder.new
        @stack = []
      end

      def start_document
        @tree.start_stream 1
        @tree.start_document [1,1], [], false
      end

      def end_document
        @tree.end_document false
        @tree.end_stream
      end

      def start_element_namespace name, attrs, prefix, uri, ns
        stack.push [name, attrs, StringIO.new]
      end

      def characters string
        stack.last.last << string
      end

      def end_element_namespace name, prefix, uri
        name, attrs, content = stack.pop
        @tree.scalar content.string if name == Emitter::SCALAR_TAG
      end
    end
  end
end
