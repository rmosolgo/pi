require 'pty'
require 'timeout'
class Pandora
  COMMANDS = {
      'love' => '+',
      'ban' => '-',
      'bookmark' => 'b',
      'history' => 'h',
      'info' => 'i',
      'explain' => 'e',
      'next' => 'n',
      'pause' => 'p',
      'unpause' => 'p',
      'tired' => 't',
      'upcoming' => 'u',
      'voldown' => '(',
      'volup' => ')',
      'quit' => 'q',
    }
  PIANOBAR_DIR = "#{ENV['HOME']}/.config/pianobar"
  PIANOBAR_BIN = "pianobar"
  CONFIG_FILE = "#{PIANOBAR_DIR}/config"

  def initialize(options={})
    ensure_configuration!
    start_pianobar!
  end

  class << self
    attr_accessor :output, :input
    COMMANDS.each do |cmd , key|
      define_method(cmd) { send_keys(key) }
    end
  end

  COMMANDS.each do |cmd , key|
    define_method(cmd) { send_keys(key) }
  end

  def send_command(cmd)
    return unless COMMANDS.keys.include?(cmd)
    send(cmd)
  end

  def station
    info
    line = read_until(/Station/)
    line[/".+"/].gsub(/"/, '')
  end

  def song
    info
    line = read_until(/\|\>  "/) || ""
    line[/".+"/]
  end

  def explanation
    explain
    line = read_until(/\(i\) We're playing/) || ""
    line.gsub(/^.+\(i\)|\r|\n|\t/, '')
  end

  def upcoming_songs
    upcoming
    first_line = read_until(/0\) /) || ""
    upcoming
    second_line = read_until(/1\) /) || ""
    upcoming
    third_line = read_until(/2\) /) || ""
    lines = [ first_line, second_line, third_line]
    lines.map{|line| line.gsub(/\r|\n/, '').sub(/^.+\d\)/, '')}
  end

  def read_until(search_regexp)
    match = nil
    Timeout::timeout(0.5) do
      while next_line = self.class.output.gets do
        if next_line =~ search_regexp
          match = next_line
          break
        end
      end
    end
    match
  rescue
    nil
  end

  private

  def send_keys(keys)
    self.class.input.puts(keys)
  end

  def start_pianobar!
    master, slave = PTY.open
    read, write = IO.pipe
    pid = spawn("#{PIANOBAR_BIN}", in: read, out: slave)
    read.close  # don't need it
    slave.close # don't need it
    self.class.output = master
    self.class.input = write
  end

  def ensure_configuration!
    raise 'No pianobar!' unless File.exist?(CONFIG_FILE)
  end
end
