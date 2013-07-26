# -*- coding: utf-8 -*-
require "futaba"
require "test/unit/rr"

class TestThread < Test::Unit::TestCase
  class TestPosts < self
    def test_posts
      thread = Futaba::Thread.new("XXX", "YYY", "ZZZ", 100)
      document =  File.read(fixture_path("thread.html"), :encoding => Encoding::Shift_JIS)
      stub(thread).open.yields(document)

      expected_posts = [
        {:body=>"赤城加賀\n天龍\n\n龍田",
          :date=>"13/07/15(月)18:47:40",
          :deleted_p=>false,
          :id=>"205659270",
          :image=>
          {:size_byte=>0,
            :thumbnail_height=>0,
            :thumbnail_uri=>"",
            :thumbnail_width=>0,
            :uri=>""},
          :name=>"としあき",
          :title=>"無念"},
        {:body=>"球磨多摩\n木曽",
          :date=>"13/07/15(日)18:47:43",
          :deleted_p=>nil,
          :id=>"205659275",
          :image=>
          {:size_byte=>0,
            :thumbnail_height=>0,
            :thumbnail_uri=>"",
            :thumbnail_width=>0,
            :uri=>""},
          :name=>"としあき",
          :title=>""},
        {:body=>"川内神通那珂",
          :date=>"13/07/15(木)18:47:46",
          :deleted_p=>nil,
          :id=>"205659277",
          :image=>
          {:size_byte=>0,
            :thumbnail_height=>0,
            :thumbnail_uri=>"",
            :thumbnail_width=>0,
            :uri=>""},
          :name=>"「」",
          :title=>"無念"},
        {:body=>"書き込みをした人によって削除されました",
          :date=>"13/07/15(火)18:47:49",
          :deleted_p=>true,
          :id=>"205659279",
          :image=>
          {:size_byte=>0,
            :thumbnail_height=>0,
            :thumbnail_uri=>"",
            :thumbnail_width=>0,
            :uri=>""},
          :name=>"としあき",
          :title=>"無念"},
      ]

      actual_posts = thread.posts.collect do |post|
        actual_post = {
          :id        => post.id,
          :title     => post.title,
          :name      => post.name,
          :date      => post.date,
          :body      => post.body,
          :deleted_p => post.deleted_p,
        }
        actual_post[:image] = {
          :uri              => post.image.uri,
          :size_byte        => post.image.size_byte,
          :thumbnail_uri    => post.image.thumbnail_uri,
          :thumbnail_height => post.image.thumbnail_height,
          :thumbnail_width  => post.image.thumbnail_width,
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
