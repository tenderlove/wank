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
        if [Emitter::MAPPING_TAG, Emitter::SEQUENCE_TAG].include?(name)
          if !stack.empty? && Emitter::SCALAR_TAGS.include?(stack.last.first)
            stack.last[3] = false
          end
        end

        stack.push [name, attrs, StringIO.new, true]
        attr_hash = Hash[*attrs.map { |x| [x.localname, x.value] }.flatten]
        tag = attr_hash.key?('class') ?
          attr_hash['class'].split(/\s/,2).join(':') : nil

        @tree.start_sequence          if name == Emitter::SEQUENCE_TAG
        @tree.start_mapping(nil, tag) if name == Emitter::MAPPING_TAG
      end

      def characters string
        stack.last[2] << string
      end

      def end_element_namespace name, prefix, uri
        name, attrs, content, write = stack.pop

        if Emitter::SCALAR_TAGS.include?(name) && write
          @tree.scalar content.string
        end

        @tree.end_sequence          if name == Emitter::SEQUENCE_TAG
        @tree.end_mapping           if name == Emitter::MAPPING_TAG
      end
    end
  end
end
