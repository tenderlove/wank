require "test/unit"
require "wank"

module Wank
  module HTML
    class TestMarshal < Test::Unit::TestCase
      def test_hash
        x = {:one => 'two', 3 => 4.0}
        assert_equal x, Marshal.load(Marshal.dump(x))
      end
    end
  end
end
