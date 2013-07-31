require "open-uri"
require "nokogiri"
require "nkf"

module Futaba
  class Thread
    attr_accessor :uri, :head_letters, :thumbnail, :n_posts

    def initialize
      @uri = ""
      @head_letters = ""
      @thumbnail = ""
      @n_posts = 0
    end

    def posts
      begin
        fetch
      rescue OpenURI::HTTPError => error
        if error.message =~ /404/
          puts "Thread disappeared: #{@uri}\n"
        else
          puts "Error: #{@uri}\n"
        end
      end
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
      post.no = extract_no(parsed_post)
      post.title = extract_title(parsed_post)
      post.name = extract_name(parsed_post)
      post.date = extract_date(parsed_post)
      post.body = extract_body(parsed_post)
      post.image = extract_image(parsed_post)
      post.deleted_p = deleted_p
      post
    end

    def extract_no(parsed_post)
      date_and_id_and_no = parsed_post.text.scan(/Name\s+\S*\s+(\d+\/\d+\/\d+\(\S+\)\d+:\d+:\d+)\s+(?:ID:(\S+)\s+)?No.(\d+)\s+del/)[0]
      raw_no = date_and_id_and_no[2]
      raw_no.to_i
    end

    def extract_title(parsed_post)
      parsed_post.xpath("font")[0].text
    end

    def extract_name(parsed_post)
      parsed_post.xpath("font")[1].text
    end

    def extract_date(parsed_post)
      date_and_id = parsed_post.text.scan(/Name\s+\S*\s+(\d+\/\d+\/\d+\(\S+\)\d+:\d+:\d+)\s+(?:ID:(\S+)\s+)?No.(\d+)\s+del/)[0]
      raw_date = date_and_id[0]
      DateTime.strptime(raw_date.gsub(/\(\S+\)/, ""), "%y/%m/%d%H:%M:%S")
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
      size_byte_raw = parsed_thumbnail["alt"]
      image.size_byte = size_byte_raw.scan(/(\d+)\s+B/).flatten[0].to_i

      thumbnail = Post::Thumbnail.new
      thumbnail.uri = parsed_thumbnail["src"]
      thumbnail.height = parsed_thumbnail["height"].to_i
      thumbnail.width = parsed_thumbnail["width"].to_i

      image.thumbnail = thumbnail
      image
    end
  end
end
