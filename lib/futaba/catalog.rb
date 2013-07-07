module Futaba
  class Catalog
    class << self
      def catalog_uri(board_uri)
        board_uri + "futaba.php?mode=cat"
      end
    end

    attr_reader :uri

    def initialize(board_uri)
      @uri = Catalog.catalog_uri(board_uri)
    end
  end
end
