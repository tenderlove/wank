require "test/unit"
require "wank"

module Wank
  module XML
    class TestMarshal < Test::Unit::TestCase
      def test_true
        x = true
        assert_equal x, Marshal.load(Marshal.dump(x))
      end
    end
  end
end
