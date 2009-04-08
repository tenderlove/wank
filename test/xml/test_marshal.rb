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

      def test_nil_is_in_xml
        doc = Nokogiri::XML(Marshal.dump(nil))
        assert_equal 1, doc.css('span').length
      end
    end
  end
end
