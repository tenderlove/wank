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
        @doc = Nokogiri::XML(@target) { |cfg| cfg.noblanks }
        @doc.root.children.each do |child|
          return __load(child)
        end
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

      def __load node
        case node['class']
        when 'TrueClass'
          true
        when 'FalseClass'
          false
        when 'NilClass'
          nil
        when 'Fixnum', 'Bignum'
          Integer(node.content)
        when 'Float'
          return -1 / 0.0 if node.content == '-Infinity'
          return 1 / 0.0 if node.content == 'Infinity'
          return 0.0 / 0.0 if node.content == 'NaN'
          Float(node.content)
        when 'String'
          node.content
        when 'Symbol'
          node.content.to_sym
        when 'Class', 'Module'
          node.content.split('::').inject(Object) { |m,s|
            m.const_get(s)
          }
        when 'Array' # this should be in C
          node.child.children.map do |li|
            __load(li.child)
          end
        when 'Hash' # this should be in C
          Hash[*(node.child.children.map { |dd_dt|
            __load(dd_dt.child)
          }.flatten)]
        when 'Struct'
          keys    = []
          values  = []
          klass = node['name'].split('::').inject(Object) { |m,s|
            m.const_get(s)
          }
          node.child.children.each do |dt_dd|
            keys    << __load(dt_dd.child) if dt_dd.name == 'dt'
            values  << __load(dt_dd.child) if dt_dd.name == 'dd'
          end
          klass.new(*values)
        else
          instance = node['class'].split('::').inject(Object) { |m,s|
            m.const_get(s)
          }.new
          node.children.each do |child|
            if child['name'] == 'ivars'
              keys    = []
              values  = []
              child.child.children.map { |dt_dd|
                keys    << __load(dt_dd.child) if dt_dd.name == 'dt'
                values  << __load(dt_dd.child) if dt_dd.name == 'dd'
              }
              keys.zip(values).each do |k,v|
                instance.instance_variable_set(k, v) # this should be in C
              end
            end
          end
          instance
        end
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
