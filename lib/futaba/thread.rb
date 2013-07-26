require "open-uri"
require "nokogiri"

module Futaba
  class Thread
    attr_reader :uri, :head_letters, :thumbnail_uri, :n_posts

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
    end
  end
end
