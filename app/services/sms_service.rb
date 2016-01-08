class SmsService
	attr_reader :success_numbers, :error_numbers

	def initialize
		@success_numbers = []
		@error_numbers = []
	end

	def format_number(num)
		num.strip!
		num.gsub!(/[^0-9]/, "")
		num.prepend("+1")
	end

	def send_message(num, sms_body)
		begin
		  sms_message = $twilio.messages.create(
		    from: ENV['TWILIO_FROM_NUMBER'],
		    to: num,
		    body: sms_body
		  )
		rescue Twilio::REST::RequestError => error
		  error_numbers.push(num)
		  puts "SMS message not sent: #{error}"
		else
		  success_numbers.push(num)
		  puts "SMS message sent to #{sms_message.to}: #{sms_message.body}"
		end
	end

	def send_messages(phone_numbers, sms_body)
		phone_numbers.each do |num|
		  format_number(num)
		  send_message(num, sms_body)
		end
	end

end