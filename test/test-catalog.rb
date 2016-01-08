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
      catalog.set_order(data[:order_type]).set_letters(0).set_threads(0)
      fetch_uri = catalog.send(:make_fetch_uri)
      assert_equal("http://may.2chan.net/b/futaba.php?mode=cat&sort=#{data[:expected_sort_number]}&cxyl=0x0x0", fetch_uri)
    end

    def test_fetch_uri_with_n_letters
      catalog = Futaba::Catalog.new("http://may.2chan.net/b/")
      catalog.set_order(:default).set_letters(999).set_threads(0)
      fetch_uri = catalog.send(:make_fetch_uri)
      assert_equal("http://may.2chan.net/b/futaba.php?mode=cat&cxyl=0x0x999", fetch_uri)
    end

    class TestNumThreads < self
      def test_fetch_uri
        catalog = Futaba::Catalog.new("http://may.2chan.net/b/")
        catalog.set_order(:default).set_letters(999).set_threads(48273)
        fetch_uri = catalog.send(:make_fetch_uri)
        assert_equal("http://may.2chan.net/b/futaba.php?mode=cat&cxyl=220x220x999", fetch_uri)
      end

      def test_fetch_uri_max
        catalog = Futaba::Catalog.new("http://may.2chan.net/b/")
        catalog.set_order(:default).set_letters(999).set_threads(-1)
        fetch_uri = catalog.send(:make_fetch_uri)
        assert_equal("http://may.2chan.net/b/futaba.php?mode=cat&cxyl=999x999x999", fetch_uri)
      end

      def test_fetch_uri_too_big
        catalog = Futaba::Catalog.new("http://may.2chan.net/b/")
        catalog.set_order(:default).set_letters(999).set_threads(1000000)
        fetch_uri = catalog.send(:make_fetch_uri)
        assert_equal("http://may.2chan.net/b/futaba.php?mode=cat&cxyl=999x999x999", fetch_uri)
      end
    end
  end

  class TestThreads < self
    def test_threads
      catalog = Futaba::Catalog.new("http://may.2chan.net/b/")
      document = File.read(fixture_path("catalog.html"), :encoding => Encoding::Shift_JIS)
      stub(catalog).open.yields(document)

      assert_equal(
        [
          {:head_letters=>nil,
           :n_posts=>11,
           :thumbnail_height=>30,
           :thumbnail_uri=>"http://hoge/fuga.jpg",
           :thumbnail_width=>50,
           :uri=>"http://may.2chan.net/b/res/0.htm"},
          {:head_letters=>"ぜかまし",
           :n_posts=>22,
           :thumbnail_height=>25,
           :thumbnail_uri=>"http://akagi/simakaze.jpg",
           :thumbnail_width=>30,
           :uri=>"http://may.2chan.net/b/res/1.htm"},
          {:head_letters=>nil,
           :n_posts=>33,
           :thumbnail_height=>40,
           :thumbnail_uri=>"http://foo/bar.png",
           :thumbnail_width=>10,
           :uri=>"http://may.2chan.net/b/res/2.htm"},
          {:head_letters=>"大和",
           :n_posts=>20,
           :uri=>"http://may.2chan.net/b/res/3.htm"},
          {:head_letters=>"Mk-Ⅱ",
           :n_posts=>42,
           :uri=>"http://may.2chan.net/b/res/4.htm"}
        ],
        catalog.threads.collect {|thread|
          actual_thread = {
            :uri => thread.uri,
            :head_letters => thread.head_letters,
            :n_posts => thread.n_posts,
          }

          if thread.thumbnail
            actual_thread[:thumbnail_uri] = thread.thumbnail.uri
            actual_thread[:thumbnail_width] = thread.thumbnail.width
            actual_thread[:thumbnail_height] = thread.thumbnail.height
          end

          actual_thread
        }
      )
    end

    def test_number_of_threads
      catalog = Futaba::Catalog.new("http://may.2chan.net/b/")
      catalog.set_threads(2)
      document = File.read(fixture_path("catalog.html"), :encoding => Encoding::Shift_JIS)
      stub(catalog).open.yields(document)

      assert_equal(2, catalog.threads.size)
    end

    private
    def fixture_path(basename)
      File.join(File.dirname(__FILE__), 'fixtures', basename)
    end
  end
end
