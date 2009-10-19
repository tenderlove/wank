module Wank
  module HTML
    class Emitter < Wank::XML::Emitter
      def start_document version, directives, implicit
        @document = Nokogiri::HTML::Document.new
        @document.encoding = 'UTF-8'

        Nokogiri::XML::Builder.new do |xml|
          xml.doc     = @document
          xml.parent  = @document
          xml.html do
            xml.head
            xml.body
          end
        end

        @stack.push @document.at('body')
      end
    end
  end
end
