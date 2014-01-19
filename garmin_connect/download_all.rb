#!/usr/bin/ruby

require 'rubygems'
require 'mechanize'
require 'date'

user = ARGV[0]
password = ARGV[1]
from_date = Date.today
if not ARGV[2].nil?
  from_date = Date.parse(ARGV[2])
end

agent = Mechanize.new { |agent|
  agent.user_agent_alias= 'Mac Safari'
  agent.pluggable_parser['text/xml'] = Mechanize::Page
  agent.pluggable_parser['application/vnd.garmin.gpx+xml'] = Mechanize::Download
}

# first log in
page = agent.get('http://connect.garmin.com/signin')
form = page.form_with(:name => 'login')

form.field_with(:name => 'login:loginUsernameField').value = user
form.field_with(:name => 'login:password').value = password
form.click_button

# fetch the last 20 workouts
page = agent.get('http://connect.garmin.com/proxy/activity-search-service-1.0/axm/activities?')

xml = Nokogiri::XML(page.body)
xml.remove_namespaces!

xml.xpath("//activity").each do |activity| 
  id = activity.attribute('idValue').value
  date_str = activity.xpath("summary/measurement[@measurementActivityField='measurementActivityField_beginTimestamp']").attribute("dateValue").value
  date = DateTime.parse(date_str)
  if date < from_date
    $stderr.puts "#{date} is before #{from_date}, breaking"
    break
  end

  url = "http://connect.garmin.com/proxy/activity-service-1.2/gpx/activity/#{id}?full=true"
  $stderr.puts "downloading #{url}"
  agent.get(url).save(id + ".gpx")
end                                    