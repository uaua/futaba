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
          :id=>205659270,
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
          :deleted_p=>nil,
          :id=>205659275,
          :name=>"としあき",
          :title=>""},
        {:body=>"川内神通那珂",
          :date=>"2013-07-15T18:47:46+00:00",
          :deleted_p=>nil,
          :id=>205659277,
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
          :id=>205659279,
          :name=>"としあき",
          :title=>"無念"},
      ]

      actual_posts = thread.posts.collect do |post|
        actual_post = {
          :id        => post.id,
          :title     => post.title,
          :name      => post.name,
          :date      => post.date.to_s,
          :body      => post.body,
          :deleted_p => post.deleted_p,
        }
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

    private
    def fixture_path(basename)
      File.join(File.dirname(__FILE__), 'fixtures', basename)
    end
  end
end
