module Futaba
  class Board
    class << self
      def normalize_uri(uri)
        matched = uri.scan(/(https:\/\/)?(\w+)\.2chan\.net\/(\w+)\/?(\S*)/).flatten
        "https://" + matched[1] + ".2chan.net/" + matched[2] + "/"
      end
    end

    attr_reader :catalog, :uri

    def initialize(uri)
      @uri = Board.normalize_uri(uri)
      @catalog = Catalog.new(uri)
    end
  end
end
