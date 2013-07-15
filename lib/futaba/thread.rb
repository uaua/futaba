module Futaba
  class Thread
    attr_reader :uri, :head_letters, :thumbnail_uri, :n_posts

    def initialize(uri, head_letters, thumbnail_uri, n_posts)
      @uri = uri
      @head_letters = head_letters
      @thumbnail_uri = thumbnail_uri
      @n_posts = n_posts
    end
  end
end
