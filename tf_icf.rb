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
  
  # icf support
  num_docs = lines.size.to_f
  number_docs_with_term = Hash.new 0
  lines.each do |terms|
    terms.uniq.each do |term|
      number_docs_with_term[term] += 1
    end
  end

  lines.each do |terms|

    rescaler = Rescaler.new MIN_FONT_SIZE, MAX_FONT_SIZE
    
    n += 1
    
    # tf support
    term_freq = Hash.new 0
    terms.each { |t| term_freq[t] += 1 }

    # calc tf/icf
    weights = {}
    terms.uniq.each do |term| 
      tf = term_freq[term].to_f / term.size
      icf = Math.log ( num_docs / number_docs_with_term[term])
      weights[t] = tf/icf
      rescaler.observe weights[t]
    end

    # rescale
    weights.each do |term,weight|
      rescaled = rescaler.rescale(weight)
      #    puts "term=#{term}, before=#{weights[term]}, after=#{rescaled}"
      weights[term] = rescaled
    end

    # remit line, font size weighted by tf/icf
    if terms.first == 'wireds'
      printf "<tr><td><strong>#{n.to_i}</strong></td><td>"
      terms.each do |term|
        weight = (weights[term] * 100).to_i.to_f / 100
        printf "<font size=#{weight}em>#{term}</font> "
      end
      printf "</td></tr>"
      return
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
STDIN.each { |l| lines << l.gsub("'",'').gsub(/[^a-z0-9]/,' ').split }

puts "<html><table>"
tf_icf lines 
puts "</table></html>"
