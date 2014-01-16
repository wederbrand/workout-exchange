#!/usr/bin/ruby

require 'nokogiri'

# read file
file = File.read(ARGV[0])
xml = Nokogiri::XML(file)

# look for all trkpt/time
xml.xpath("//trkpt/time").each do |time|
  puts time
end

# find time between each

