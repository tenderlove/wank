require "test/unit"
require "wank"

module Wank
  module XML
    class TestMarshal < Test::Unit::TestCase
      def fact(n)
        return 1 if n == 0
        f = 1
        while n>0
          f *= n
          n -= 1
        end
        return f
      end

      def test_marshal
        x = [1, 2, 3, [4,5,"foo"], {1=>"bar"}, 2.5, fact(30)]
        assert_equal x, Marshal.load(Marshal.dump(x))

        [[1,2,3,4], [81, 2, 118, 3146]].each { |w,x,y,z|
          obj = (x.to_f + y.to_f / z.to_f) * Math.exp(w.to_f / (x.to_f + y.to_f / z.to_f))
          assert_equal obj.to_s, Marshal.load(Marshal.dump(obj)).to_s
        }
      end

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

      #def test_class
      #  x = Marshal
      #  assert_equal x, Marshal.load(Marshal.dump(x))
      #end

      #def test_module
      #  x = XML
      #  assert_equal x, Marshal.load(Marshal.dump(x))
      #end

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
        y = Struct.new(:foo).new('bar')
        z = Marshal.load Marshal.dump(Struct.new(:foo).new('bar'))
        assert_equal y.foo, z.foo
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
    end
  end
end
