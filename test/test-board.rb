require "futaba"

class TestBoard < Test::Unit::TestCase
  class TestURI < self
    class << self
      def generate_test_name(uri)
        "test_uri_pattern_" + URI_PATTERNS.index(uri).to_s
      end
    end

    URI_PATTERNS = [
      "http://may.2chan.net/b",
      "http://may.2chan.net/b/",
      "http://may.2chan.net/b/futaba.htm",
      "http://may.2chan.net/b/futaba.php",
    ]

    URI_PATTERNS.each do |uri|
      method_name = generate_test_name(uri)
      define_method(method_name) do
        board = Futaba::Board.new(uri)
        assert_uri(board.uri)
      end
    end

    def assert_uri(actual_board_uri)
      expected_board_uri = "http://may.2chan.net/b/"
      assert_equal(expected_board_uri, actual_board_uri)
    end
  end
end
