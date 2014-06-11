#!/usr/bin/ruby

require 'rubygems'
require 'mechanize'

# abort "#{$0} login passwd filename" if (ARGV.size != 3)

puts ARGV[2]

a = Mechanize.new { |agent|
  agent.follow_meta_refresh = true
}

home_page = a.get('http://www.strava.com/')
signin_page = a.click(home_page.link_with(:text => /Log In/))

form = signin_page.form_with(:id => 'login_form');
form.email  = 'andreas@wederbrand.se' #ARGV[0]
form.password = 'ash3ml1gt' #ARGV[1]
my_page = form.submit

# Click the upload link
upload_page = a.click(my_page.link_with(:text => /Upload/))

# Upload from File
upload_page = a.click(upload_page.link_with(:text => /File/))

# Upload the files
upload_page.form_with(:method => 'POST') do |upload_form|
  upload_form.file_uploads.first.file_name = ARGV[2]
end.submit
