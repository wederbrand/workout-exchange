#!/usr/bin/ruby

require 'rubygems'
require 'mechanize'
require 'date'

email = ARGV[0]
password = ARGV[1]
file = ARGV[2]

agent = Mechanize.new { |agent|
  agent.user_agent_alias= 'Mac Safari'
  agent.pluggable_parser['text/xml'] = Mechanize::Page
}

# first log in
page = agent.get('https://www.endomondo.com/login')

form = page.form_with(:class => 'signInForm')
form.field_with(:name => 'email').value = email
form.field_with(:name => 'password').value = password
form.click_button

page = agent.get('http://www.endomondo.com/workouts/create')

onclick = page.links.find {|link| link.text.include?("gpx")}.attributes["onclick"]
link = onclick[/'.*?'/].reverse.chop.reverse.chop

page = agent.get('http://www.endomondo.com/' + link)
page = agent.get('http://www.endomondo.com/' + page.iframe.src)

# upload form
form = page.form
form.action = page.link_with(:text => 'Next').attributes['onclick'][/wicketSubmitFormById.*',/][30..-3]
form.add_field!("uploadSumbit", value = nil)
form.file_upload.file_name = file
page = form.submit

# review form
form = page.form
form.action = page.link_with(:text => 'Save').attributes['onclick'][/wicketSubmitFormById.*',/][30..-3]
form.add_field!("reviewSumbit", value = nil)
form.fields[1].option_with(:text => "Cycling, sport").click
page = form.submit
