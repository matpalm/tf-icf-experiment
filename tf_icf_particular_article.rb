#!/usr/bin/env ruby

MIN_FONT_SIZE = 2.0
MAX_FONT_SIZE = 5.0
FIRST_TERM_IN_ARTICLE = ARGV.shift
SECOND_TERM_IN_ARTICLE = ARGV.shift


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

Result = Struct.new :n, :text_with_font_weightings

def tf_icf lines
  corpus_freq = Hash.new 0
  n = 0.0
  lines.each do |terms|
    rescaler = Rescaler.new MIN_FONT_SIZE, MAX_FONT_SIZE
    n += 1

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

    if terms[0]==FIRST_TERM_IN_ARTICLE && terms[1]==SECOND_TERM_IN_ARTICLE
     td_content = ""
#      printf "<tr><td><strong>#{n.to_i}</strong></td><td>"
      terms.each do |term|
        weight = (weights[term] * 100).to_i.to_f / 100
        td_content += "<td><font size=#{weight}em>#{term}</font></td>"
      end
#      td_content += "</td>"
#printf "</td></tr>"
      return Result.new n.to_i, td_content
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
results = 100.times.collect do
  lines.shuffle!
  tf_icf lines 
end
results.sort {|a,b| a.n <=> b.n }.each do |result|
  puts "<tr><td>#{result.n}<td><td>#{result.text_with_font_weightings}</td></tr>"
end
puts "</table></html>"
