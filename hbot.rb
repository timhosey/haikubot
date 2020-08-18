require 'syllabize'
require 'rubygems'
require 'mini_magick'
require 'twitter'

def make_image(text)
  img = MiniMagick::Image.open('img/base.jpg')

  img.combine_options do |c|
    c.gravity 'Southeast'
    c.draw "text 50,10 '#{text}'"
    c.font './Ounen-mouhitsu.otf'
    c.pointsize 72
    c.stroke '#000000'
    c.strokewidth 1
    c.fill('#b9b9b9')
  end

  img.write('img/new.jpg')
end

@words = []

def get_line(line_length)
  line = ''
  line_syl = 0
  while line_syl < line_length
    line_syl += @words[0].downcase.gsub(/[^a-z0-9\s]/i, '').chomp.count_syllables
    line += if line == ''
              @words[0]
            else
              " #{@words[0]}"
            end
    # Removes the word from the list entirely
    @words.reject!.with_index { |_v, i| i == 0 }
  end
  abort "Unable to make clean #{line_length}-syllable sentence (#{line})" if line.count_syllables > line_length
  line
end

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = 'yRdSUEMRlQrbwQ9i37V8fT3K8'
  config.consumer_secret     = 'bhh1T79obF1RQYHTuWhdUBW1sXqFEjIpffNxvM6FCawlTvaFkV'
  config.access_token        = '2798026922-HLjTtuQoCEwsCsknhFijWKzw6ZckV2tjEjoxYpI'
  config.access_token_secret = 'zxzTDj8od3SpOFXqt4dNo725u2H34OWjH7al5fSWoeHZl'
end

client.sample do |object|
  puts object.text if object.is_a?(Twitter::Tweet)
end

puts 'Enter sentence:'
phrase = gets
fixed_phrase = phrase.downcase.gsub(/[^a-z0-9\s]/i, '').chomp
total_syl = fixed_phrase.count_syllables
if total_syl == 17
  puts "Phrase has exactly #{total_syl} syllables."
  @words = phrase.split(' ')
  lines = ['', '', '']

  # First line. 5 syllables.
  lines[0] = get_line(5)

  # Second line. 7 syllables.
  lines[1] = get_line(7)

  # Third line. 5 syllables.
  lines[2] = get_line(5)
  puts lines
  make_image("#{lines[0]}\n#{lines[1]}\n#{lines[2]}")
else
  abort_text = total_syl > 17 ? 'too many' : 'too few'
  abort "Phrase has #{abort_text} syllables (#{total_syl})!"
end