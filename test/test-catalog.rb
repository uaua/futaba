require "futaba"

class TestCatalog < Test::Unit::TestCase
  class TestURI < self
    def test_uri
      catalog = Futaba::Catalog.new("http://may.2chan.net/b/")
      assert_equal("http://may.2chan.net/b/futaba.php?mode=cat", catalog.uri)
    end
  end
end
