#!/usr/bin/env ruby
STDIN.each do |line| 
  puts line.downcase.gsub("'",'').gsub(/[^a-z0-9]/,' ').gsub(/\s+/,' ').strip
end
