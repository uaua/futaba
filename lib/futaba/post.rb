require "futaba/post/image"
require "futaba/post/thumbnail"

module Futaba
  class Post
    attr_accessor :no, :title, :name, :id, :date, :body, :image, :deleted_p

    def initialize
      @no = 0
      @title = ""
      @name = ""
      @id = ""
      @date = nil
      @body = ""
      @image = nil
      @deleted_p = false
    end
  end
end
