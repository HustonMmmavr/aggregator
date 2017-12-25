require 'yaml'
class Consumer
  # KEY = "recent_posts" # redis key
  STORE_LIMIT = 20      # how many posts should be kept

  # Get list of recent posts from redis
  # Since redis stores data in binary text format
  # we need to parse each list item as JSON
  def self.list(limit = STORE_LIMIT)
    $redis.lrange(KEY, 0, limit-1).map do |raw_post|
      p raw_post
      JSON.load(raw_post).with_indifferent_access
    end
  end

  def self.top()

  end

  def self.size()
    return $redis.dbsize()
  end

  def self.pop(key)
    # p $redis.dbsize()
    data = nil
    # if $redis.dbsize() != 0
     data = $redis.brpop(key, :timeout => 10)
    # end
    data
  end
     # if data != nil
       # data = JSON.load(data, :timeout => 5)
     # end
     # data
  # end
  # Push new post to list and trim it's size
  # to limit required storage space
  # `raw_post` is already a JSON string
  # so there is no need to encode it as JSON
  def self.push(key, raw_post)
    $redis.lpush(key, raw_post)
    $redis.ltrim(key, 0, STORE_LIMIT-1)
  end
end
