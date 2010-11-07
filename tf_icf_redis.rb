#!/usr/bin/env ruby
require 'rubygems'

debug = ARGV.include? 'debug'

if ARGV.include? 'fake'
  require 'fake_redis'
else
  require 'redis' # https://github.com/ezmobius/redis-rb
end

kv_store = Redis.new

STDIN.each do |text|
  text.chomp!
  kv_store.incr('n')

  terms = text.split
  
  freq = Hash.new 0
  terms.each { |t| freq[t] += 1 }
  freq.keys.each { |uniq_term| kv_store.incr("t_#{uniq_term}") }

  if terms[0]=='chastise' && terms[1]=='apples'
    n = kv_store.get('n').to_f
    terms.uniq.sort.each do |token|       
      corpus_freq = kv_store.get("t_#{token}").to_i
      lhs = Math.log(1+freq[token])
      rhs = Math.log((n+1.0)/(corpus_freq+1))
      weight = lhs * rhs
      # printf "token %20s tf=%5i cf=%5i lhs=%0.3f rhs=%0.3f weight=%0.3f\n", t, freq[t], corpus_freq[t], lhs, rhs, weight
      puts [n,token,weight].join("\t")
    end
  end

end

