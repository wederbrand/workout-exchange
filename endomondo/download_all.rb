#!/usr/bin/ruby

require 'rubygems'
require 'mechanize'
require 'date'

email = ARGV[0]
password = ARGV[1]
format = ARGV[2]
from_date = Date.today
if not ARGV[3].nil?
  from_date = Date.parse(ARGV[3])
end

agent = Mechanize.new { |agent|
  agent.user_agent_alias= 'Mac Safari'
  agent.pluggable_parser['text/xml'] = Mechanize::Page
}

# first log in
page = agent.get('https://www.endomondo.com/access')
form = page.form_with(:name => 'signInForm')

form.field_with(:name => 'email').value = email
form.field_with(:name => 'password').value = password
form.click_button

# fetch the workout page
page = agent.get('http://www.endomondo.com/workouts')
              
# get current year
year = page.search('//span[@class="year"]')[0].text.to_i              
# get current month
month = page.search('//li[@class="current"]/a/@onclick').first.value.match(/months:(\d+):month/)[1].to_i+1
# get current day
day = page.search('//div[div/span[@class="selected"]]/span')[0].text.to_i

target_date = Date.new(year, month, day)
# to store all workouts
workouts = Array.new
                                         
while target_date >= from_date do
  # add all workouts from this day, if any
  $stderr.puts "checking #{target_date}"
  page.search("//td[not(contains(@class, 'not-in-month'))]/div[span[@class='cday'][.=#{target_date.day}]]/div/span/a/@href").each do |link|
    workouts.push(link.value)
    $stderr.puts "found #{link.value}"
  end
  
  if (target_date.day == 1)
    $stderr.puts "changing month"
    # got to previous month 
    # find current month
    # todo to to previous year if needed (month = 1)
    if (target_date.month == 1)
      $stderr.puts "changing year"
      prev_year_link = page.search('//a[@class="previous"]/@href').first.value
      page = agent.get(prev_year_link)
    else  
      prev_month_link = page.search('//div[@class="month-nav"]//li[@class="current"]').first.previous_sibling.search('a/@href').first.value
      page = agent.get(prev_month_link)
    end
        
    # create link for previous month
    # click linke
  
  end
  target_date -= 1;  
end 

workouts.each { |href|
  $stderr.puts "fetching #{href}"
  page = agent.get(href)
  export = page.link_with(:text => 'Export')
  if (export.nil?) 
    $stderr.puts "missing export link, skipping"
    next
  end
  link = export.attributes['onclick'].match(/wicketAjaxGet\('(.*wicket.+?)'/)[1]
  # $stderr.puts "found #{link}"
  href = href + "/" + link
  # $stderr.puts "joined link #{href}"
  page = agent.get(href)
  link = page.link_with(:text => /#{format}/).href
  page = agent.get("http://www.endomondo.com/workouts/#{link}")
  xml = Nokogiri::XML(page.body)
  xml.remove_namespaces!
  type = xml.search('//trk/type').text.downcase.sub(/_/, '')
  dude = xml.search('//trk/trkseg/trkpt/time').first
  date = DateTime.parse(xml.search('//trk/trkseg/trkpt/time').first.text)
  filename = "#{date.strftime('%Y%m%d-%H%M')}_#{type}_endomondo.gpx"
  $stderr.puts " to #{filename}"  
  page.save_as(filename)
}
