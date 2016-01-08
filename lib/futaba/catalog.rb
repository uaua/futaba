require "open-uri"
require "nokogiri"
require "nkf"

require "futaba/thread/thumbnail"

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
      uri = make_fetch_uri

      threads = []
      open(uri, "r:CP932") do |document|
        parsed_document = Nokogiri::HTML(document.read.encode("cp932", invalid: :replace, undef: :replace))
        threads = extract_threads(parsed_document)
      end
      threads
    end

    def extract_threads(parsed_document)
      threads = []
      parsed_document.xpath('//table[@align="center"]/tr').each do |tr|
        tr.xpath('td').each do |td|
          if n_threads < 0
            if threads.size >= MAX_CATALOG_SIZE[:x] * MAX_CATALOG_SIZE[:y]
              break
            end
          else
            if threads.size >= n_threads
              break
            end
          end
          threads << extract_thread(td)
        end
      end
      threads
    end

    def extract_thread(parsed_td)
      uri = @board_uri + parsed_td.at("a")["href"]
      head_letters = parsed_td.at("small").text if parsed_td.at("small")
      n_posts = parsed_td.at("font").text.to_i

      thread = Futaba::Thread.new
      thread.uri = uri
      thread.head_letters = head_letters
      thread.n_posts = n_posts

      thread.thumbnail = nil
      parsed_thumbnail = parsed_td.at("a").at("img")
      if parsed_thumbnail
      thumbnail_uri = parsed_td.at("a").at("img")["src"]
      thumbnail_width = parsed_td.at("a").at("img")["width"].to_i
      thumbnail_height = parsed_td.at("a").at("img")["height"].to_i

      thumbnail = Futaba::Thread::Thumbnail.new
      thumbnail.uri = thumbnail_uri
      thumbnail.width = thumbnail_width
      thumbnail.height = thumbnail_height

      thread.thumbnail = thumbnail
      end

      thread
    end

    def make_fetch_uri
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
      max_p ||= n_threads > MAX_CATALOG_SIZE[:x] * MAX_CATALOG_SIZE[:y]
      if max_p
        x = MAX_CATALOG_SIZE[:x]
        y = MAX_CATALOG_SIZE[:y]
      else
        x = Math.sqrt(n_threads).ceil
        if x > 0
          y = (n_threads / x.to_f).ceil
        else
          y = 0
        end
      end
      uri += "&cxyl=#{x}x#{y}x#{n_letters}"
    end
  end
end
