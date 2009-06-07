module Wank
  module HTML
    class Marshal < Wank::XML::Marshal
      def to_s
        @doc.root = Element.new('html', @doc)
        @doc.root << Element.new('body', @doc)
        @parent = @doc.root.children.first
        dump @target
        @doc.to_xhtml
      end

      def to_o
        @doc = Nokogiri::XML(@target) { |cfg| cfg.noblanks }
        @doc.at('body').children.each do |child|
          return __load(child)
        end
      end
    end
  end
end
