#!/usr/bin/env ruby

MIN_FONT_SIZE = 2.0
MAX_FONT_SIZE = 5.0

############################################

class Rescaler

  def initialize final_min,final_max
    raise "whatchoo talking bout willis" if final_max <= final_min
    @final_min = final_min
    @final_diff = final_max - final_min
    @final_average = (final_max + final_min).to_f / 2
  end

  def observe n
    if @observed_min.nil?
      @observed_min = @observed_max = n
    elsif n < @observed_min
      @observed_min = n
    elsif n > @observed_max
      @observed_max = n
    end
  end
  
  def rescale n
    raise "i DAAAAAAAAANT believe it!" if @observed_max.nil?

    diff = @observed_max-@observed_min
    return @final_average if diff==0

    n = n.to_f
    n -= @observed_min
    n /= diff
    n *= @final_diff
    n += @final_min
    n
  end

end

def tf_icf lines
  corpus_freq = Hash.new 0
  n = 0.0
  lines.each do |text|
    rescaler = Rescaler.new MIN_FONT_SIZE, MAX_FONT_SIZE
    STDERR.puts(text) if text =~ /^with udo/
    
    text = text.gsub("'",'')

    #  puts "------------------------"
    #  puts text

    n += 1

    terms = text.gsub(/[^a-z0-9]/,' ').split
    
    freq = Hash.new 0
    terms.each { |t| freq[t] += 1 }
    freq.keys.each { |uniq_term| corpus_freq[uniq_term] += 1 }

    weights = {}
    terms.each do |t| 
      weight = Math.log(1+freq[t]) * Math.log((n+1)/(corpus_freq[t]+1)) 
      weights[t] = weight
      rescaler.observe weight
    end

    weights.each do |term,weight|
      rescaled = rescaler.rescale(weight)
      #    puts "term=#{term}, before=#{weights[term]}, after=#{rescaled}"
      weights[term] = rescaled
    end
    
    if (n<20 || n%50==0) 
      printf "<tr><td>#{n.to_i}</td><td>"
      terms.each do |term|
        weight = (weights[term] * 100).to_i.to_f / 100
        printf "<font size=#{weight}em>#{term}</font> "
      end
      printf "</td></tr>\n"
    end

=begin
       STDERR.puts "freq (#{freq.size}) #{freq.sort { |a,b| b[1]<=>a[1] }.inspect}"
       corpus_freq_subset = corpus_freq.select{|k,v| freq.keys.include?(k)}
       STDERR.puts "corpus_freq subset (#{corpus_freq_subset.size}) #{corpus_freq_subset.sort{|a,b| b[1]<=>a[1] }.inspect}"
       #  STDERR.puts "corpus_freq (#{corpus_freq.size}) #{corpus_freq.sort{|a,b| b[1]<=>a[1] }.inspect}"
       weights_sorted = weights.sort { |a,b| b[1]<=>a[1] }  
       STDERR.puts weights_sorted.inspect
=end

  end

end

lines = []
STDIN.each { |l| lines << l }

puts "<html><table>"
tf_icf lines
puts "</table></html>"
