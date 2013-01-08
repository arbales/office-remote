require 'bundler/setup'
require 'sinatra/base'

class Office < Sinatra::Base

  def tell(application, command)
    application = application.to_s.capitalize

    # AppleScript Content
    osa = <<-EOT
      tell application "#{application}"
        #{command}
      end tell
    EOT
    # Issue command view the shell. 
    system "osascript <<END \n#{osa}\nEND"
  end
  
  get '/' do
    [701, "Meh"]
  end
  
  post '/volume/increment' do
     step = (params[:step] || 7).to_i
    `osascript -e 'set volume output volume (output volume of (get volume settings) + #{step})'`
    204
  end

  delete '/volume/increment' do
    step = (params[:step] || 7).to_i
    `osascript -e 'set volume output volume (output volume of (get volume settings) - #{step})'`    
    204
  end

  put '/volume' do
    volume = (params[:volume] || 0).to_i
    `osascript -e 'set volume output volume #{volume}'`
    204
  end

  put '/spotify' do
    unless action = params[:action]
      halt 422
    end
    action.downcase!
    
    case action
    when 'play', 'pause', 'playpause'
      tell :spotify, action
    when 'next'
      tell :spotify, 'next track'
    when 'previous'
      tell :spotify, 'next previous'
    when 'open'
      tell :spotify, "open location #{params[:url]}"
    else
      halt 422
    end
    
    [202, "Command issued."]
  end
end

run Office
