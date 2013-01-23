require 'bundler/setup'
require 'sinatra/base'

module Office
  module AppleScript
    def osa(script, multiline=false)
      script = multiline ? "osascript <<END \n#{script}\nEND" : "osascript -e '#{script}'"
      `#{script}`
    end
    
    def tell(application, command)
      application = application.to_s.capitalize
    
      # AppleScript Content
      script = <<-EOT
        tell application "#{application}"
          #{command}
        end tell
      EOT
      # Issue command view the shell.
      osa script, true
    end
    
    def set_volume(volume)
      osa "set volume output volume #{volume}"
    end
    
    def current_volume
      "output volume of (get volume settings)"
    end
    
    def step_volume(amount = 1)
      set_volume "(#{current_volume} + #{amount})"
    end
    
    # Crossfades volume.
    # TODO: Write an AppleScript version of this instead.
    def crossfade(&block)
      Thread.new do
        volume = osa(current_volume).to_i
        step = 5
        fade(volume, -step)
        block.call
        fade(volume, step)
      end
    end
    
    # Fades volume towards a given amount by stepping.
    def fade(amount, step)
      (amount / step.abs).times do
        step_volume step
      end
    end
  end
end

module Office
  module ShellScripts
    def resurrect
      `git reset --hard && git pull --rebase origin master && bundle && kill -s HUP \`cat tmp/office.pid\``
    end

    def play(name)
      sound_path = File.expand_path("../public/#{name}.mp3", __FILE__)
      puts sound_path
      `afplay #{sound_path}`
    end
  end
end

module Office
  class Application < Sinatra::Base
    include Office::AppleScript
    include Office::ShellScripts
    
    get '/' do
      haml :index
    end
    
    get '/restart' do
      resurrect
      "Restarting. By your command."
    end

    post '/volume/increment' do
      step = (params[:step] || 7).to_i
      step_volume step
      204
    end
  
    delete '/volume/increment' do
      step = (params[:step] || 7).to_i
      step_volume -step
      204
    end
  
    put '/volume' do
      volume = (params[:volume] || 0).to_i
      set_volume volume
      204
    end

    post '/warning/generic' do
      Thread.new do
        5.times do
          play('alert')
          sleep 0.25
          play('alert')
          sleep 3
        end
      end
      204
    end

    post '/paging/:name' do
      name = params[:name].gsub('-', ' ')
      play('hailing')
      `say '#{name}. #{name}, please'`
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
        crossfade do
          tell :spotify, 'next track'
        end
      when 'previous'
        crossfade do
          tell :spotify, 'next previous'
        end
      when 'open'
        crossfade do
          tell :spotify, "open location \"#{params[:url]}\""
        end
      else
        halt 422
      end
      
      [202, "Command issued."]
    end
  end
end
run Office::Application
