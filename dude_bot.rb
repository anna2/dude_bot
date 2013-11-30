require 'net/http'
require 'json'

class ZulipBot
	def initialize(email, api_key)
		@email = email
		@api_key = api_key
		@queue_id = nil
		@last_event_id = nil
		@current_events = nil
	end

	def send_stream_msg(stream, subject, message)
		uri = URI('https://api.zulip.com/v1/messages')
		req = Net::HTTP::Post.new(uri)
		req.set_form_data(
					'type' => 'stream',
					'to' => stream,
					'subject' => subject,
					'content' => message
					)
		req.basic_auth(@email, @api_key)

		res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https')  {|http|
			http.request(req)
		}
	end

	def send_pm(recipient, message)
		uri = URI('https://api.zulip.com/v1/messages')
		req = Net::HTTP::Post.new(uri)
		req.set_form_data(
			'type' => 'private',
			'to' => recipient,
			'content' => message
			)
		req.basic_auth(@email, @api_key)
		res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https')  {|http|
			http.request(req)
		}
	end

	#create a queue to watch for events of a specified type
	def register(event_type)
		uri = URI("https://api.zulip.com/v1/register")
		req = Net::HTTP::Post.new(uri)
		req.set_form_data('event_types' => event_type)
		req.basic_auth(@email, @api_key)
		res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https')  {|http|
			http.request(req)
		}
		@queue_id = JSON.parse(res.body)["queue_id"]
		@last_event_id = JSON.parse(res.body)["last_event_id"]
	end

	#get new events out of the queue
	def get_events(regex)
		uri = URI("https://api.zulip.com/v1/events")
		params = {last_event_id: @last_event_id, queue_id: @queue_id}
		uri.query = URI.encode_www_form(params)
		req = Net::HTTP::Get.new(uri)
		req.basic_auth(@email, @api_key)
		res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https')  {|http|
			http.request(req)
		}
		@current_events = JSON.parse(res.body)
		unless @current_events["events"].nil?
			extract_message(@current_events, regex)
		end
	end

	#check events' content for regex matches
	def extract_message(events_hash, regex)
		events_hash["events"].each do |event|
			if event["message"]["content"].downcase.match(regex)
				stream = event["message"]["display_recipient"]
				subject = event["message"]["subject"]
				message = get_quotes
				self.send_stream_msg(stream, subject, message)
				@last_event_id = event["message"]["id"] + 1
			end
		end
	end

	#a quote fetching method specifically for the sample dude-bot
	#re-open and overwrite for other bots
	def get_quotes
		quotes = [
			"Well, sir, it's this rug I had. It really tied the room together.",
			"Look, let me explain something to you. I'm not Mr. Lebowski. You're Mr. Lebowski. I'm the Dude. So that's what you call me. That, or His Dudeness … Duder … or El Duderino, if, you know, you're not into the whole brevity thing.",
			"This is a very complicated case, Maude. You know, a lotta ins, lotta outs, lotta what-have-you's. And, uh, lotta strands to keep in my head, man. Lotta strands in old Duder's head. Luckily I'm adhering to a pretty strict, uh, drug regimen to keep my mind limber.",
			"Careful, man, there's a beverage here!",
			"Yeah, well. The Dude abides.",
			"Yeah,well, that's just, like, your opinion, man.",
			"This aggression will not stand man.",
			"At least I'm housebroken.",
			"I can't be worrying about that shit. Life goes on, man.",
			"Ha hey, this is a private residence man."
		]
		quotes.fetch(rand(quotes.size))
	end
end


#a sample bot using the above bindings
dude = ZulipBot.new('BOT_EMAIL', 'API_KEY')
dude.register(JSON.unparse(['message']))
loop do
	dude.get_events(/dude/)
end