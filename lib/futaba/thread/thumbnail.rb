module Futaba
  class Thread
    class Thumbnail
      attr_accessor :uri, :height, :width

      def initialize
        @uri = ""
        @height = 0
        @width = 0
      end
    end
  end
end
