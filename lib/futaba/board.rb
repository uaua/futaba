module Futaba
  class Board
    class << self
      def normalize_uri(uri)
        matched = uri.scan(/(http:\/\/)?(\w+)\.2chan\.net\/(\w+)\/?(\S*)/).flatten
        "http://" + matched[1] + ".2chan.net/" + matched[2] + "/"
      end
    end

    attr_reader :uri

    def initialize(uri)
      @uri = Board.normalize_uri(uri)
    end
  end
end
