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

      def dump o
        visitor = Psych::Visitors::YASTBuilder.new
        visitor.accept(o)
        yaml_ast = visitor.tree
        emitter = Class.new(Psych::Visitors::Emitter) {
          attr_accessor :handler
          def initialize handler
            @handler = handler
          end
        }.new(XML::Emitter.new)

        emitter.accept(yaml_ast)
        emitter.handler.documents.first.to_xml
      end

      def to_s
        dump(@target)
      end

      def to_o
        doc = XML::Parser.new
        Nokogiri::XML::SAX::Parser.new(doc).parse(@target)
        doc.tree.root.to_ruby.first
      end

      private
      def push node_name
        @parent = @parent.add_child(Node.new(node_name, @doc))
        if block_given?
          yield @parent
          pop
        end
        @parent
      end

      def pop
        @parent = @parent.parent
      end

      ###
      # Add some text to the current parent node
      def text text
        @parent.add_child(Text.new(text, @doc))
      end

      def set_class class_name
        if class_name =~ /^#/
          raise TypeError, ("can't dump anonymous %s" % class_name)
        end
        @parent['class'] = class_name
      end

      def __dump_ivars list
        return if list.length == 0
        push("div") { |div|
          div['name'] = 'ivars'
          push("dl") { |dl|
            list.each do |ivar_name|
              push('dt') { dump(ivar_name) }
              push('dd') { __dump_ivar(@target, ivar_name.to_sym) }
            end
          }
        }
      end
    end
  end
end
