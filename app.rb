require 'sinatra'
require "sinatra/reloader" if development?

class Pandora
  COMMANDS = {
      'love' => '+',
      'ban' => '-',
      'bookmark' => 'b',
      'history' => 'h',
      'info' => 'i',
      'next' => 'n',
      'pause' => 'p',
      'unpause' => 'p',
      'tired' => 't',
      'upcoming' => 'u',
      'voldown' => '(',
      'volup' => ')'
    }
  LOG_FILE = "~/.config/pianobar/log.log"
  PIPE_FILE = "~/.config/pianobar/ctl"

  def self.log_length
    `sed -n '$=' #{LOG_FILE}`.to_i
  end

  def self.now_playing

  end

  def self.send_keys(keys)
    `echo '#{keys}' > #{PIPE_FILE}`
  end

  def self.send_command(cmd)
    keys = COMMANDS[cmd]
    result = send_keys(keys)
  end
end

get '/pandora' do
  "Log length: #{Pandora.log_length}<br>" +
  Pandora::COMMANDS.keys.map{|k| "<a href='/pandora/#{k}' target='_blank'>#{k}</a>"}.join("<br/>")
end



get '/pandora/:cmd' do
  Pandora.send_command(params[:cmd]) || "ok (#{cmd})"
end


get "/" do
  "Hello Whirl"
end
