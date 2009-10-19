module Wank
  module HTML
    class Marshal < Wank::XML::Marshal
      def dump o
        visitor = Psych::Visitors::YASTBuilder.new
        visitor.accept(o)
        yaml_ast = visitor.tree
        emitter = Class.new(Psych::Visitors::Emitter) {
          attr_accessor :handler
          def initialize handler
            @handler = handler
          end
        }.new(HTML::Emitter.new)

        emitter.accept(yaml_ast)
        emitter.handler.document.to_xhtml
      end
    end
  end
end
