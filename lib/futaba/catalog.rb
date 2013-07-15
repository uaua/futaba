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

    def fetch(order_type: :default)
      uri = make_fetch_uri(order_type)

      open(uri) do |document|
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

    def make_fetch_uri(order_type)
      uri = @uri
      case order_type
      when :newer
        uri += "&sort=1"
      when :older
        uri += "&sort=2"
      when :increasing
        uri += "&sort=3"
      when :decreasing
        uri += "&sort=4"
      end
      uri
    end
  end
end
