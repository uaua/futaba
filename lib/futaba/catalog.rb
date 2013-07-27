require "open-uri"
require "nokogiri"

module Futaba
  class Catalog
    class << self
      def catalog_uri(board_uri)
        board_uri + "futaba.php?mode=cat"
      end
    end

    attr_reader :uri

    MAX_CATALOG_SIZE = { :x => 999, :y => 999 }

    def initialize(board_uri)
      @board_uri = board_uri
      @uri = Catalog.catalog_uri(board_uri)
    end

    def threads
      fetch
    end

    def order_type
      @order_type ||= :default
    end

    def set_order(order_type)
      tap { @order_type = order_type }
    end

    def n_letters
      @n_letters ||= 0
    end

    def set_letters(n_letters)
      tap { @n_letters = n_letters }
    end

    def n_threads
      @n_threads ||= -1
    end

    def set_threads(n_threads)
      tap { @n_threads = n_threads }
    end

    private
    def fetch
      uri = make_fetch_uri(order_type, n_letters, n_threads)

      threads = []
      open(uri) do |document|
        parsed_document = Nokogiri::HTML(document)
        threads = extract_threads(parsed_document)
      end
      threads
    end

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

      thread = Futaba::Thread.new
      thread.uri = uri
      thread.head_letters = head_letters
      thread.thumbnail_uri = thumbnail_uri
      thread.n_posts = n_posts
      thread
    end

    def make_fetch_uri(order_type, n_letters, n_threads)
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
      max_p = n_threads < 0
      x = MAX_CATALOG_SIZE[:x]
      y = max_p ? MAX_CATALOG_SIZE[:y] : (n_threads / x.to_f).ceil
      uri += "&cxyl=#{x}x#{y}x#{n_letters}"
    end
  end
end
