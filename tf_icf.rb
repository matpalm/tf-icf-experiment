#!/usr/bin/env ruby

corpus_freq = Hash.new 0
n = 0

STDIN.each do |text|
  text.chomp!
  n += 1

  terms = text.split
  
  freq = Hash.new 0
  terms.each { |t| freq[t] += 1 }
  freq.keys.each { |uniq_term| corpus_freq[uniq_term] += 1 }

  terms.uniq.sort.each do |token| 
    lhs = Math.log(1+freq[token])
    rhs = Math.log((n+1)/(corpus_freq[token]+1))
    weight = lhs * rhs
    # printf "token %20s tf=%5i cf=%5i lhs=%0.3f rhs=%0.3f weight=%0.3f\n", t, freq[t], corpus_freq[t], lhs, rhs, weight
    puts [n,token,weight].join("\t")
  end

end

