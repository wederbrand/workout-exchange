#!/usr/bin/ruby

require 'nokogiri'
require 'time'
require 'pp'

# read file
file = File.read(ARGV[0])

# create a new dom to fill as I like
xml = Nokogiri::XML(file)
new_xml = Nokogiri::XML(file)
new_xml.xpath("//xmlns:trk").remove

# look for all trkpt/time
last_time = Time.strptime(xml.xpath("//xmlns:trkpt/xmlns:time").first.text, "%FT%T.%L%Z")
xml.xpath("//xmlns:trkpt").each do |trkpt|
  current_time = Time.strptime(trkpt.xpath("xmlns:time").text, "%FT%T.%L%Z")
  time_diff = current_time.to_i - last_time.to_i
  
  if time_diff > 60 then
    # put a <pause/> here for now, we'll replace it later
    trkpt.add_previous_sibling("<pause/>")
  end  
  
  last_time = current_time  
end

# create new track segments for every pause and recreate the xml from the resulting string
xml = Nokogiri::XML(xml.to_s.gsub("<pause/>", "</trkseg><trkseg>")) do |config| 
  config.default_xml.noblanks
end

# output the xml in a nice way
puts xml.to_xml(:indent => 2)

