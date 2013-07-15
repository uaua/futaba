# -*- coding: utf-8 -*-
require "futaba"
require "test/unit/rr"

class TestCatalog < Test::Unit::TestCase
  class TestURI < self
    def test_uri
      catalog = Futaba::Catalog.new("http://may.2chan.net/b/")
      assert_equal("http://may.2chan.net/b/futaba.php?mode=cat", catalog.uri)
    end

    data({
        "newer" => {
          :order_type => :newer,
          :expected_sort_number => 1,
        },
        "older" => {
          :order_type => :older,
          :expected_sort_number => 2,
        },
        "increasing" => {
          :order_type => :increasing,
          :expected_sort_number => 3,
        },
        "decreasing" => {
          :order_type => :decreasing,
          :expected_sort_number => 4,
        },
      })
    def test_fetch_uri_with_order_type(data)
      catalog = Futaba::Catalog.new("http://may.2chan.net/b/")
      fetch_uri = catalog.send(:make_fetch_uri, data[:order_type])
      assert_equal("http://may.2chan.net/b/futaba.php?mode=cat&sort=#{data[:expected_sort_number]}", fetch_uri)
    end
  end

  class TestThreads < self
    def test_threads
      catalog = Futaba::Catalog.new("http://may.2chan.net/b/")
      document = File.read(fixture_path("catalog.html"), :encoding => Encoding::Shift_JIS)
      stub(catalog).open.yields(document)

      catalog.fetch

      assert_equal(
        [
          {:head_letters=>nil,
            :n_posts=>11,
            :thumbnail_uri=>"http://hoge/fuga.jpg",
            :uri=>"http://may.2chan.net/b/res/0.htm"},
          {:head_letters=>"ぜかまし",
            :n_posts=>22,
            :thumbnail_uri=>"http://akagi/simakaze.jpg",
            :uri=>"http://may.2chan.net/b/res/1.htm"},
          {:head_letters=>nil,
            :n_posts=>33,
            :thumbnail_uri=>"http://foo/bar.png",
            :uri=>"http://may.2chan.net/b/res/2.htm"}
        ],
        catalog.threads.collect {|thread|
          {
            :uri => thread.uri,
            :head_letters => thread.head_letters,
            :thumbnail_uri => thread.thumbnail_uri,
            :n_posts => thread.n_posts,
          }
        }
      )
    end

    private
    def fixture_path(basename)
      File.join(__dir__, 'fixtures', basename)
    end
  end
end
