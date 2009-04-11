require "test/unit"
require "wank"

module Wank
  module XML
    class TestMarshal < Test::Unit::TestCase
      def test_true
        x = true
        assert_equal x, Marshal.load(Marshal.dump(x))
      end

      def test_false
        x = false
        assert_equal x, Marshal.load(Marshal.dump(x))
      end

      def test_nil
        x = nil
        assert_equal x, Marshal.load(Marshal.dump(x))
      end

      def test_fixnum
        x = 2
        assert_equal x, Marshal.load(Marshal.dump(x))
      end

      def test_float
        x = 2.2
        assert_equal x, Marshal.load(Marshal.dump(x))
      end

      def test_negative_infinity
        x = -1 / 0.0
        assert_equal x, Marshal.load(Marshal.dump(x))
      end

      def test_positive_infinity
        x = 1 / 0.0
        assert_equal x, Marshal.load(Marshal.dump(x))
      end

      def test_nan
        x = 0.0 / 0.0
        assert Marshal.load(Marshal.dump(x)).nan?
      end

      def test_string
        x = "foo"
        assert_equal x, Marshal.load(Marshal.dump(x))
      end

      def test_class
        x = Marshal
        assert_equal x, Marshal.load(Marshal.dump(x))
      end

      def test_module
        x = XML
        assert_equal x, Marshal.load(Marshal.dump(x))
      end

      def test_array
        x = [1, "two", 3.0]
        assert_equal x, Marshal.load(Marshal.dump(x))
      end

      def test_hash
        x = {:one => 'two', 3 => 4.0}
        assert_equal x, Marshal.load(Marshal.dump(x))
      end

      def test_empty_hash
        x = {}
        assert_equal x, Marshal.load(Marshal.dump(x))
      end

      X = Struct.new(:foo)
      def test_struct
        x = X.new('bar')
        assert_equal x, Marshal.load(Marshal.dump(x))
      end

      def test_anon_struct
        assert_raise(TypeError) {
          Marshal.dump(Struct.new(:foo).new('bar'))
        }
      end

      class F < Object
      end

      def test_object
        x = F.new
        assert_instance_of F, Marshal.load(Marshal.dump(x))
      end

      class G < Object
        attr_accessor :foo
        def initialize
          @foo = nil
        end
      end

      def test_object_with_ivar
        x = G.new
        x.foo = "bar"
        y = Marshal.load(Marshal.dump(x))
        assert_equal "bar", y.instance_variable_get(:@foo)
      end

      def test_symbol
        x = :foo
        assert_equal x, Marshal.load(Marshal.dump(x))
      end

      def test_nil_is_in_xml
        doc = Nokogiri::XML(Marshal.dump(nil))
        assert_equal 1, doc.css('span').length
      end
    end
  end
end
