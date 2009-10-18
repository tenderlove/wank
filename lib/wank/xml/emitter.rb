module Wank
  module XML
    class Emitter
      attr_accessor :documents

      SCALAR_TAG = 'p'

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

      def scalar value, anchor, tag, plain, quoted, style
        node             = Nokogiri::XML::Node.new(SCALAR_TAG, @stack.last.document)
        node.parent      = @stack.last
        node.content     = value
        node['data-tag'] = tag if tag
      end

      def end_document implicit
        @documents << @stack.pop
      end

      def end_stream
      end
    end
  end
end
