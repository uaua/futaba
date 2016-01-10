require "open-uri"
require "nokogiri"

module Futaba
  class Thread
    DATE_ID_NO_PATTERN = /Name\s+\S*\s+(\d+\/\d+\/\d+\(\S+\)\d+:\d+:\d+)\s+(?:ID:(\S+)\s+)?No.(\d+)\s+del/

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
          p error
        end
        []
      rescue => error
        puts "Error: #{@uri}\n"
        p error
        []
      end
    end

    private
    def fetch
      posts = []
      open(uri, "r:binary") do |document|
        parsed_document = Nokogiri::HTML(document.read.encode("utf-8", "cp932", invalid: :replace, undef: :replace))
        posts = extract_posts(parsed_document)
      end
      posts
    end

    def extract_posts(parsed_document)
      posts = []
      thread_body = parsed_document.xpath('//form[not(@enctype="multipart/form-data")]')
      posts << extract_post(thread_body) # there are parent post in top structure

      thread_body.xpath("table").each do |table|
        deleted_p = (table["class"] && (table["class"] == "deleted")) || false
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
      post.id = extract_id(parsed_post)
      post.mailto = extract_mailto(parsed_post)
      post.date = extract_date(parsed_post)
      post.body = extract_body(parsed_post)
      post.image = extract_image(parsed_post)
      post.deleted_p = deleted_p
      post
    end

    def extract_no(parsed_post)
      date_and_id_and_no = parsed_post.text.scan(DATE_ID_NO_PATTERN)[0]
      raw_no = date_and_id_and_no[2]
      raw_no.to_i
    end

    def extract_title(parsed_post)
      parsed_post.xpath("font")[0].text
    end

    def extract_name(parsed_post)
      parsed_post.xpath("font")[1].text
    end

    def extract_id(parsed_post)
      date_and_id_and_no = parsed_post.text.scan(DATE_ID_NO_PATTERN)[0]
      raw_id = date_and_id_and_no[1]
      raw_id
    end

    def extract_mailto(parsed_post)
      mailto_href = parsed_post.xpath("font")[1].at('a[href ^="mailto:"]/@href')
      if mailto_href
        mailto_href.value.scan(/mailto:(\S+)/).flatten[0]
      else
        nil
      end
    end

    def extract_date(parsed_post)
      date_and_id = parsed_post.text.scan(DATE_ID_NO_PATTERN)[0]
      raw_date = date_and_id[0]
      DateTime.strptime(raw_date.gsub(/\(\S+\)/, ""), "%y/%m/%d%H:%M:%S")
    end

    def extract_body(parsed_post)
      body_node = parsed_post.xpath("blockquote").children

      body = body_node.collect { |node|
        if node.name == "br"
          "\n"
        else
          node.text
        end
      }.join

      body
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
