class Redis

  def initialize
    @hash = Hash.new 0
  end
  
  def flushdb
  end

  def incr token
    @hash[token] += 1
  end

  def get token
    @hash[token]
  end

end
