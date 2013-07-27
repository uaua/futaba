module Futaba
  class Post
    class Image
      attr_accessor :uri, :size_byte,
                    :thumbnail_uri, :thumbnail_height, :thumbnail_width

      def initialize
        @uri = ""
        @size_byte = 0
        @thumbnail_uri = ""
        @thumbnail_height = 0
        @thumbnail_width = 0
      end
    end
  end
end
