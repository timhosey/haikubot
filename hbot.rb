require 'syllabize'
require 'rubygems'
require 'mini_magick'
require 'twitter'

def escape_characters_in_string(string)
  pattern = /(\'|\"|\.|\*|\/|\-|\\)/
  string.gsub(pattern){|match|"\\"  + match} # <-- Trying to take the currently found match and add a \ before it I have no idea how to do that).
end

def make_image(text, id)
  img = MiniMagick::Image.open('img/base.jpg')

  img.combine_options do |c|
    c.gravity 'Northeast'
    c.pointsize 82
    c.stroke '#000000'
    c.draw "text 50,30 '#{text}'"
    c.font './Mansalva-Regular.ttf'
    c.strokewidth 2
    c.fill('#cccccc')
  end

  img.write("img/#{id}.jpg")
end

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
  if line.count_syllables > line_length
    puts "Unable to make clean #{line_length}-syllable sentence (#{line})"
    return false
  end
  line
end

def check_tweets(tweets_num)
  puts "Checking #{tweets_num} latest tweets..."
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = 'yRdSUEMRlQrbwQ9i37V8fT3K8'
    config.consumer_secret     = 'bhh1T79obF1RQYHTuWhdUBW1sXqFEjIpffNxvM6FCawlTvaFkV'
    config.access_token        = '2798026922-HLjTtuQoCEwsCsknhFijWKzw6ZckV2tjEjoxYpI'
    config.access_token_secret = 'zxzTDj8od3SpOFXqt4dNo725u2H34OWjH7al5fSWoeHZl'
  end

  client.search('(#gaming OR #games OR #ghostoftsushima OR #ghostsoftsushima OR #videogames OR #fallguys) -rt', result_type: 'recent', lang: 'en').take(tweets_num).collect do |tweet|
    @words = []
    # puts "#{tweet.user.screen_name}: #{tweet.text}"
    t_text = tweet.text.dup
    t_name = tweet.user.screen_name.dup
    # puts "Tweet ##{tweet.id}"
    # this removes @ and # entries
    # t_text.gsub!(/\B[@#]\S+\b/, '')
    t_text.gsub!(/#{URI::regexp}/, '')
    if File.exist?("img/#{tweet.id}.jpg")
      puts "File exists for #{tweet.id}. Skipping."
      next
    end

    total_syl = t_text.count_syllables
    if total_syl == 17
      puts "Tweet #{tweet.user.id} has exactly #{total_syl} syllables."
      @words = escape_characters_in_string(t_text).tr('#@$','').split(' ')
      lines = ['', '', '']

      # First line. 5 syllables.
      lines[0] = get_line(5)
      next if !lines[0]

      # Second line. 7 syllables.
      lines[1] = get_line(7)
      next if !lines[1]

      # Third line. 5 syllables.
      lines[2] = get_line(5)
      next if !lines[2]
      puts "Generated Haiku from Tweet ##{tweet.id}!"
      puts lines
      make_image("#{lines[0]}\n#{lines[1]}\n#{lines[2]}\n- @#{t_name}", tweet.id)
    else
      abort_text = total_syl > 17 ? 'too many' : 'too few'
      puts "Phrase has #{abort_text} syllables (#{total_syl})!"
    end
  end

  tweet_timeout(60)
end

def tweet_timeout(wait_time)
  puts "Waiting #{wait_time} seconds before next poll..."
  wait_time.downto(0) do |i|
    sleep 1
  end

  check_tweets(100)
end

check_tweets(100)
