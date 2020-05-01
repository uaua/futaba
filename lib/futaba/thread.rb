# coding: utf-8
require "open-uri"
require "nokogiri"
require "openssl"

module Futaba
  class Thread
    DATE_ID_PATTERN = /(\d\d\/\d\d\/\d\d\(\S\)\d\d:\d\d:\d\d)\s?(?:ID:(\S+))?(?:IP:(\S+))?/

    attr_accessor :id, :uri, :head_letters, :thumbnail, :n_posts

    def initialize
      @id = ""
      @uri = ""
      @head_letters = ""
      @thumbnail = ""
      @n_posts = 0
    end

    def posts(options)
      begin
        p = URI.parse(@uri)
        @url = "#{p.scheme}://#{p.host}"
        fetch(options)
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
        STDERR.puts error.backtrace.join("\n")
        []
      end
    end

    private
    def fetch(options)
      posts = []
      OpenURI.open_uri(uri, "r:binary", options) do |document|
        parsed_document = Nokogiri::HTML(document.read.encode("utf-8", "cp932", invalid: :replace, undef: :replace))
        posts = extract_posts(parsed_document)
      end
      posts
    end

    def extract_posts(parsed_document)
      posts = []
      thread_body = parsed_document.xpath('//div[@class = "thre"]')
      posts << extract_post(thread_body) # there are parent post in top structure

      thread_body.xpath("table").each do |table|
        deleted_p = (table["class"] && (table["class"] == "deleted")) || false
        parsed_post = table.xpath('tr/td[@class = "rtd"]')
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
      post.ip = extract_ip(parsed_post)
      post.mailto = extract_mailto(parsed_post)
      post.date = extract_date(parsed_post)
      post.body = extract_body(parsed_post)
      post.image = extract_image(parsed_post)
      post.deleted_p = deleted_p
      post.soudane = extract_soudane(parsed_post)
      post
    end

    def extract_soudane(parsed_post)
      parsed_post.xpath('a[@class = "sod"]')&.text&.match(/そうだねx(\d+)/)&.to_a&.at(1)&.to_i || 0
    end

    def extract_no(parsed_post)
      # skip "No."
      parsed_post.xpath('span[@class="cno"]').text[3..].to_i
    end

    def extract_title(parsed_post)
      parsed_post.xpath('span[@class="csb"]').text
    end

    def extract_name(parsed_post)
      parsed_post.xpath('span[@class="cnm"]').text
    end

    def extract_ip(parsed_post)
      parsed_post.xpath('span[@class="cnw"]').text.scan(DATE_ID_PATTERN).first[2]
    end

    def extract_id(parsed_post)
      parsed_post.xpath('span[@class="cnw"]').text.scan(DATE_ID_PATTERN).first[1]
    end

    def extract_mailto(parsed_post)
      parsed_post.xpath('span[@class="cnm"]').at('a[href ^="mailto:"]/@href')&.value&.scan(/mailto:(\S+)/)&.flatten&.first
    end

    def extract_date(parsed_post)
      raw_date = parsed_post.xpath('span[@class="cnw"]').text.scan(DATE_ID_PATTERN).first[0]
      raw_date << " +0900"
      DateTime.strptime(raw_date.gsub(/\(\S+\)/, ""), "%y/%m/%d%H:%M:%S %z")
    end

    def extract_body(parsed_post)
      parsed_post.xpath("blockquote").inner_html
    end

    def extract_image(parsed_post)
      parsed_thumbnail = parsed_post.at('img')
      return nil unless parsed_thumbnail

      image = Post::Image.new
      image.uri = "#{@url}#{parsed_thumbnail.parent["href"]}"
      size_byte_raw = parsed_thumbnail["alt"]
      image.size_byte = size_byte_raw.scan(/(\d+)\s+B/).flatten[0].to_i

      thumbnail = Post::Thumbnail.new
      thumbnail.uri = "#{@url}#{parsed_thumbnail["src"]}"
      thumbnail.height = parsed_thumbnail["height"].to_i
      thumbnail.width = parsed_thumbnail["width"].to_i

      image.thumbnail = thumbnail
      image
    end
  end
end
