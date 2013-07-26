require "futaba"
require "test/unit/rr"

class TestThread < Test::Unit::TestCase
  class TestPosts < self
    def test_posts
      thread = Futaba::Thread.new("XXX", "YYY", "ZZZ", 100)
      document =  File.read(fixture_path("thread.html"), :encoding => Encoding::Shift_JIS)
      stub(thread).open.yields(document)

      assert_equal(4, thread.posts.size)
    end

    private
    def fixture_path(basename)
      File.join(File.dirname(__FILE__), 'fixtures', basename)
    end
  end
end
