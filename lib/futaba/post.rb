require "futaba/post/image"
require "futaba/post/thumbnail"

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
  end
end
