require "csv"
require "sunlight/congress"
require "erb"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
	zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zipcode)
	Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def clean_phone_number(phone_number)
	input = phone_number.to_s
	phone_number = ""
	bad_number = (Array.new(10) { 0 }).join

	input.each_char do |c|
		phone_number << c if c =~ /\d/
	end

	if phone_number.length == 10
		return format_phone_number(phone_number)
	elsif phone_number.length == 11 && phone_number.start_with?("1")
		return format_phone_number(phone_number[1..11])
	else
		return format_phone_number(bad_number)
	end
end

def format_phone_number(number)
	"(#{number[0..2]}) #{number[3..5]}-#{number[6..9]}"
end

def save_thank_you_letters(id, form_letter)
	Dir.mkdir("output") unless Dir.exists? "output"

	filename = "output/thanks_#{id}.html"

	File.open(filename,'w') do |file|
		file.puts form_letter
	end
end

puts "Event Manager Initialized!"

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
contents.each do |row|
	id = row[0]
	name = row[:first_name]

	zipcode = clean_zipcode(row[:zipcode])

	phone_number = clean_phone_number(row[:homephone])



	legislators = legislators_by_zipcode(zipcode)

	puts "#{name} #{phone_number}"

	# form_letter = erb_template.result(binding)

	# save_thank_you_letters(id, form_letter)
end
