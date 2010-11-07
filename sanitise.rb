#!/usr/bin/env ruby
STDIN.each do |line| 
  puts line.gsub("'",'').gsub(/[^a-z0-9]/,' ').gsub(/\s+/,' ').strip
end
