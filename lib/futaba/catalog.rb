require "open-uri"
require "nokogiri"

module Futaba
  class Catalog
    class << self
      def catalog_uri(board_uri)
        board_uri + "futaba.php?mode=cat"
      end
    end

    attr_reader :threads, :uri

    def initialize(board_uri)
      @board_uri = board_uri
      @uri = Catalog.catalog_uri(board_uri)
    end

    def fetch
      open(@uri) do |document|
        parsed_document = Nokogiri::HTML(document)
        @threads = extract_threads(parsed_document)
      end
    end

    private
    def extract_threads(parsed_document)
      threads = []
      parsed_document.xpath('//table[@align="center"]/tr').each do |tr|
        tr.xpath('td').each do |td|
          threads << extract_thread(td)
        end
      end
      threads
    end

    def extract_thread(parsed_td)
      uri = @board_uri + parsed_td.at("a")["href"]
      head_letters = parsed_td.at("small").text if parsed_td.at("small")
      thumbnail_uri = parsed_td.at("a").at("img")["src"]
      n_posts = parsed_td.at("font").text.to_i

      Futaba::Thread.new(
        uri,
        head_letters,
        thumbnail_uri,
        n_posts)
    end
  end

  Thread = Struct.new(
    :uri,
    :head_letters,
    :thumbnail_uri,
    :n_posts
  )
end
