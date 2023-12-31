require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone(phone)
  
  phone.gsub!(/\D/,'')

  if phone.length == 10
    phone
  elsif phone.length == 11 && phone[0] == '1'
    phone.slice!(0)
    phone
  elsif phone.length == 11 && phone[0] != '1'
    'Invalid phone number'
  elsif phone.length < 10 || phone.length > 11
    'Invalid phone number'
  end

end

def display_legislators(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end

end

def save_thanks_letter(id, form_letter)
  
  Dir.mkdir('output') unless Dir.exist?('output')
  
  filename = "output/thanks_#{id}.html"
  
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end

end


puts "EventManager initialized."


contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])
  phone = clean_phone(row[:homephone])

  legislators = display_legislators(zipcode)

  #form_letter = erb_template.result(binding)

  #save_thanks_letter(id, form_letter)
  puts phone
end
