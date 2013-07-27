module Futaba
  class Post
    class Image
      attr_accessor :uri, :size_byte, :thumbnail

      def initialize
        @uri = ""
        @size_byte = 0
        @thumbnail = nil
      end
    end
  end
end
