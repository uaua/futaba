module Futaba
  class Post
    attr_reader :id, :title, :name, :date, :body, :image, :deleted_p

    def initialize(id, title, name, date, body, image, deleted_p)
      @id = id
      @title = title
      @name = name
      @date = date
      @body = body
      @image = image
      @deleted_p = deleted_p
    end

    class Image
      attr_reader :uri, :size_byte,
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

