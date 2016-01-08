# -*- coding: utf-8 -*-
require "futaba"
require "test/unit/rr"

class TestThread < Test::Unit::TestCase
  class TestPosts < self
    def test_posts
      thread = Futaba::Thread.new
      document =  File.read(fixture_path("thread.html"), :encoding => Encoding::Shift_JIS)
      stub(thread).open.yields(document)

      expected_posts = [
        {:body=>"赤城加賀\n天龍\n\n龍田",
          :date=>"2013-07-15T18:47:40+00:00",
          :deleted_p=>false,
          :no=>205659270,
          :image=>
          {:size_byte=>999,
            :thumbnail_height=>250,
            :thumbnail_uri=>"http://aaa.com/s/bbbs.png",
            :thumbnail_width=>200,
            :uri=>"http://aaa.com/bbb.png"},
          :name=>"としあき",
          :title=>"無念"},
        {:body=>"球磨多摩\n木曽",
          :date=>"2013-07-15T18:47:43+00:00",
          :deleted_p=>false,
          :mailto=>"sage",
          :no=>205659275,
          :name=>"としあき",
          :title=>""},
        {:body=>">球磨多摩\nhamaguri\n>木曽\ntintin",
          :date=>"2013-07-15T18:47:44+00:00",
          :deleted_p=>false,
          :mailto=>"sage",
          :no=>205659276,
          :name=>"としあき",
          :title=>""},
        {:body=>"Mk-Ⅱ",
          :date=>"2013-07-15T18:47:45+00:00",
          :deleted_p=>false,
          :mailto=>"sage",
          :no=>205659277,
          :name=>"としあき",
          :title=>""},
        {:body=>"川内神通那珂",
          :date=>"2013-07-15T18:47:46+00:00",
          :deleted_p=>false,
          :no=>205659277,
          :id=>"5rwACGI2",
          :image=>
          {:size_byte=>9999,
            :thumbnail_height=>550,
            :thumbnail_uri=>"http://ccc.com/s/ddds.png",
            :thumbnail_width=>400,
            :uri=>"http://ccc.com/ddd.png"},
          :name=>"「」",
          :title=>"無念"},
        {:body=>"書き込みをした人によって削除されました",
          :date=>"2013-07-15T18:47:49+00:00",
          :deleted_p=>true,
          :no=>205659279,
          :name=>"としあき",
          :title=>"無念"},
      ]

      actual_posts = thread.posts.collect do |post|
        actual_post = {
          :no        => post.no,
          :title     => post.title,
          :name      => post.name,
          :date      => post.date.to_s,
          :body      => post.body,
          :deleted_p => post.deleted_p,
        }
        actual_post[:id] = post.id if post.id
        actual_post[:mailto] = post.mailto if post.mailto
        actual_post[:image] = {
          :uri              => post.image.uri,
          :size_byte        => post.image.size_byte,
          :thumbnail_uri    => post.image.thumbnail.uri,
          :thumbnail_height => post.image.thumbnail.height,
          :thumbnail_width  => post.image.thumbnail.width,
        } if post.image
        actual_post
      end

      assert_equal(expected_posts, actual_posts)
    end

    def test_posts_raise_httperror
      thread = Futaba::Thread.new
      thread.uri = "http://foobar.com/thread.htm"
      stub(thread).open do
        raise OpenURI::HTTPError.new("404 Not Found", StringIO.new)
      end
      assert_equal("Thread disappeared: #{thread.uri}", hook_stdout{thread.posts}.chomp)
    end

    private
    def fixture_path(basename)
      File.join(File.dirname(__FILE__), 'fixtures', basename)
    end

    def hook_stdout
      begin
        old_stdout = $stdout
        $stdout = StringIO.new
        yield
        $stdout.string
      ensure
        $stdout = old_stdout
      end
    end
  end
end
