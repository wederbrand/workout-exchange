#!/usr/bin/ruby

require 'rubygems'
require 'mechanize'
require 'date'

email = ARGV[0]
password = ARGV[1]
format = ARGV[2]
until_date = Date.today
if not ARGV[3].nil?
  until_date = Date.parse(ARGV[3])
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
link = page.search('//div[@class="workoutSectionSelector"]//li[2]/a')[0].attributes['onclick'].value.match(/wicketAjaxGet\('(.*wicket.+?)'/)[1]
page = agent.get("http://www.endomondo.com/workouts#{link}")
page.save_as("list.html")

# to store all workouts
workouts = Array.new

loop do
  # all workouts on this page
  page.search('//div//tr/td[@class="date"]/a').each { |a|
    href = a.get_attribute('href')
    date = Date.parse(a.text)
    if date >= until_date
      puts "added #{href}"
      workouts.push(href)
    else
      puts "ignored #{href}, too old"
    end
  }

  # if the nav-back span doesn't hold a link we're at the last one and it's time to exit
  break if page.search('//span[@class="nav-back"]/a').empty?

  # if we didn't break we'll go to the next page now
  link = page.search('//span[@class="nav-back"]/a')[0].attributes["onclick"].value.match(/wicketAjaxGet\('(.*wicket.+?)'/)[1]
  page = agent.get("http://www.endomondo.com/workouts#{link}")
end

# now download each workout
# TODO: don't download to file, download directly to STDOUT as zip

workouts.each { |href|
  puts "fetching #{href}"
  page = agent.get(href)
  link = page.link_with(:text => 'Export').attributes['onclick'].match(/wicketAjaxGet\('(.*wicket.+?)'/)[1]
  page = agent.get("http://www.endomondo.com/workouts/#{link}")
  link = page.link_with(:text => /#{format}/).href
                        page = agent.get("http://www.endomondo.com/workouts/#{link}")
                        page.save_as("#{href.slice(/\d+/)}.#{format}")
                        }
