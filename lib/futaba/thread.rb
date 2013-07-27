require "open-uri"
require "nokogiri"
require "nkf"

module Futaba
  class Thread
    attr_accessor :uri, :head_letters, :thumbnail_uri, :n_posts

    def initialize(uri, head_letters, thumbnail_uri, n_posts)
      @uri = uri
      @head_letters = head_letters
      @thumbnail_uri = thumbnail_uri
      @n_posts = n_posts
    end

    def posts
      fetch
    end

    private
    def fetch
      posts = []
      open(@uri) do |document|
        parsed_document = Nokogiri::HTML(document)
        posts = extract_posts(parsed_document)
      end
      posts
    end

    def extract_posts(parsed_document)
      posts = []
      thread_body = parsed_document.xpath('//form[not(@id="fm")]')
      posts << extract_post(thread_body) # there are parent post in top structure

      thread_body.xpath("table").each do |table|
        deleted_p = (table["class"] && (table["class"] == "deleted"))
        parsed_post = table.xpath("tr/td")
        posts << extract_post(parsed_post, deleted_p)
      end
      posts
    end

    def extract_post(parsed_post, deleted_p=false)
      post = Post.new
      post.id = extract_id(parsed_post)
      post.title = extract_title(parsed_post)
      post.name = extract_name(parsed_post)
      post.date = extract_date(parsed_post)
      post.body = extract_body(parsed_post)
      post.image = extract_image(parsed_post)
      post.deleted_p = deleted_p
      post
    end

    def extract_id(parsed_post)
      date_and_id = parsed_post.text.scan(/Name\s+\S*\s+(\d+\/\d+\/\d+\(\S+\)\d+:\d+:\d+)\s+No.(\d+)\s+del/)[0]
      date_and_id[1]
    end

    def extract_title(parsed_post)
      parsed_post.xpath("font")[0].text
    end

    def extract_name(parsed_post)
      parsed_post.xpath("font")[1].text
    end

    def extract_date(parsed_post)
      date_and_id = parsed_post.text.scan(/Name\s+\S*\s+(\d+\/\d+\/\d+\(\S+\)\d+:\d+:\d+)\s+No.(\d+)\s+del/)[0]
      date_and_id[0]
    end

    def extract_body(parsed_post)
      body_node = parsed_post.xpath("blockquote").children
      if body_node.children.empty?
        body_sjis_html = body_node.to_html
      else
        body_sjis_html = body_node.children.to_html
      end
      body_sjis = body_sjis_html.gsub(/<br *\/*>/, "\n")
      body_utf8 = NKF.nkf("-wxm0", body_sjis)
      body_utf8
    end

    def extract_image(parsed_post)
      parsed_thumbnail = parsed_post.at('img')
      return nil unless parsed_thumbnail

      image = Post::Image.new
      image.uri = parsed_thumbnail.parent["href"]
      image.size_byte = parsed_thumbnail["alt"]

      thumbnail = Post::Thumbnail.new
      thumbnail.uri = parsed_thumbnail["src"]
      thumbnail.height = parsed_thumbnail["height"]
      thumbnail.width = parsed_thumbnail["width"]

      image.thumbnail = thumbnail
      image
    end
  end
end
