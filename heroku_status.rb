require 'bundler'
require 'rest-client'
require 'json'

def play(name)
  sound_path = File.expand_path("../public/#{name}", __FILE__)
  puts sound_path
  `afplay #{sound_path}`
end

failure = false
   
while true do
	response = RestClient.get 'https://status.heroku.com/api/v3/current-status'
	puts response.code
	puts response.headers[:server]
	data = JSON.parse(response.body)
	
	if (data["status"]["Production"] == "green") && failure
		failure = false
		play('restored.wav')
	end
	
	if data["status"]["Production"] != "green"
		failure = true
		3.times do
			play('alert.mp3')
			sleep 0.5
			play('alert.mp3')
			sleep 3
		end
	end
	sleep 15
end