require "futaba/post/image"
require "futaba/post/thumbnail"

module Futaba
  class Post
    attr_accessor :no, :title, :name, :date, :body, :image, :deleted_p

    def initialize
      @no = 0
      @title = ""
      @name = ""
      @date = nil
      @body = ""
      @image = nil
      @deleted_p = false
    end
  end
end
