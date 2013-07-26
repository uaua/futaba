module Futaba
  class Post
    attr_accessor :id, :title, :name, :date, :body, :image, :deleted_p

    def initialize
      @id = 0
      @title = ""
      @name = ""
      @date = ""
      @body = ""
      @image = nil
      @deleted_p = false
    end

    class Image
      attr_accessor :uri, :size_byte,
                  :thumbnail_uri, :thumbnail_height, :thumbnail_width

      def initialize(uri, size_byte,
          thumbnail_uri, thumbnail_height, thumbnail_width)
        @uri = uri
        @size_byte = size_byte
        @thumbnail_uri = thumbnail_uri
        @thumbnail_height = thumbnail_height
        @thumbnail_width = thumbnail_width
      end
    end
  end
end

