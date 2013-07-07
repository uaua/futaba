module Futaba
  class Thread < Struct.new(
      :uri,
      :head_letters,
      :thumbnail_uri,
      :n_posts
  )
  end
end
