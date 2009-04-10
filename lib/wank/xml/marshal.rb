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

      def to_s
        add_root!

        @parent = @doc.root

        dump(@target)

        @doc.to_xml
      end

      def to_o
        @doc = Nokogiri::XML(@target, nil, nil, PARSE_NOBLANKS)
        @doc.root.children.each do |child|
          return __load(child)
        end
      end

      private
      def push node_name
        @parent = @parent.add_child(Node.new(node_name, @doc))
      end

      def pop
        @parent = @parent.parent
      end

      def __load node
        return true if node['class']   == 'TrueClass'
        return false if node['class']  == 'FalseClass'
        return nil if node['class']    == 'NilClass'
        return Integer(node.content) if node['class'] == 'Fixnum'
        if node['class'] == 'Float'
          return -1 / 0.0 if node.content == '-Infinity'
          return 1 / 0.0 if node.content == 'Infinity'
          return 0.0 / 0.0 if node.content == 'NaN'
          return Float(node.content) if node['class'] == 'Float'
        end
        return node.content if node['class'] == 'String'
        return node.content.to_sym if node['class'] == 'Symbol'
        if %w{ Class Module }.include?(node['class'])
          return node.content.split('::').inject(Object) { |m,s|
            m.const_get(s)
          }
        end

        if node['class'] == 'Array'
          return node.child.children.map do |li|
            __load(li.child)
          end
        end

        if node['class'] == 'Hash'
          return Hash[*(node.child.children.map { |dd_dt|
            __load(dd_dt.child)
          }.flatten)]
        end

        if node['class'] == 'Struct'
          keys    = []
          values  = []
          klass = node['name'].split('::').inject(Object) { |m,s|
            m.const_get(s)
          }
          node.child.children.each do |dd_dt|
            keys    << __load(dd_dt.child) if dd_dt.name == 'dt'
            values  << __load(dd_dt.child) if dd_dt.name == 'dd'
          end
          return klass.new(*values)
        end

        node['class'].split('::').inject(Object) { |m,s|
          m.const_get(s)
        }.new
      end

      ###
      # Add some text to the current parent node
      def text text
        @parent.add_child(Text.new(text, @doc))
      end

      def add_root!
        @doc.root = Element.new('marshal', @doc)
      end

      def set_class class_name
        if class_name =~ /^#/
          raise TypeError, ("can't dump anonymous %s" % class_name)
        end
        @parent['class'] = class_name
      end
    end
  end
end
