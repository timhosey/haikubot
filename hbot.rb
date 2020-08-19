require 'syllabize'
require 'rubygems'
require 'mini_magick'
require 'twitter'
require "swearjar"

sj = Swearjar.default

def escape_characters_in_string(string)
  pattern = /(\'|\"|\.|\*|\/|\-|\\)/
  string.gsub(pattern){|match|"\\"  + match} # <-- Trying to take the currently found match and add a \ before it I have no idea how to do that).
end

def make_image(text, id)
  # Picks a base image. Base images are in img/* and labeled as base_*
  base_img_list = Dir['./img/base_*.jpg']
  base_img = base_img_list.sample
  base_img_number = File.basename(base_img, '.*' ).gsub('base_', '')

  # Changing settings based on image so they look nice.
  base_img_settings = {
    '1': {
      'gravity': 'Northeast',
      'pointsize': 82,
      'fill': '#cccccc',
    },
    '2': {
      'gravity': 'East',
      'pointsize': 82,
      'fill': '#cccccc',
    },
    '3': {
      'gravity': 'South',
      'pointsize': 82,
      'fill': '#cccccc',
    },
    '4': {
      'gravity': 'East',
      'pointsize': 82,
      'fill': '#cccccc',
    },
    '5': {
      'gravity': 'Southeast',
      'pointsize': 82,
      'fill': '#cccccc',
    },
    '6': {
      'gravity': 'Center',
      'pointsize': 82,
      'fill': '#cccccc',
    },
    '7': {
      'gravity': 'West',
      'pointsize': 82,
      'fill': '#cccccc',
    },
    '8': {
      'gravity': 'East',
      'pointsize': 82,
      'fill': '#cccccc',
    },
    '9': {
      'gravity': 'East',
      'pointsize': 82,
      'fill': '#cccccc',
    },
    '10': {
      'gravity': 'East',
      'pointsize': 82,
      'fill': '#cccccc',
    },
    '11': {
      'gravity': 'East',
      'pointsize': 82,
      'fill': '#cccccc',
    },
    '12': {
      'gravity': 'Center',
      'pointsize': 82,
      'fill': '#cccccc',
    },
  }

  img = MiniMagick::Image.open(base_img)

  img.combine_options do |c|
    c.gravity base_img_settings[:"#{base_img_number}"][:gravity]
    c.pointsize base_img_settings[:"#{base_img_number}"][:pointsize]
    c.stroke '#000000'
    c.draw "text 50,30 '#{text}'"
    c.font './Mansalva-Regular.ttf'
    c.strokewidth 2
    c.fill(base_img_settings[:"#{base_img_number}"][:fill])
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

  # Get keys and secrets from local file (not in repo anymore...)
  # In file ./creds add each on a newline matching below
  creds = File.readlines('./creds')
  client = Twitter::REST::Client.new do |config|
    config.consumer_key        = creds[0].chomp
    config.consumer_secret     = creds[1].chomp
    config.access_token        = creds[2].chomp
    config.access_token_secret = creds[3].chomp
  end

  generated_haiku = false

  search_terms = '(#gaming OR #games OR #ghostoftsushima OR #ghostsoftsushima OR #videogames OR #fallguys) -rt'
  client.search(search_terms, result_type: 'recent', lang: 'en').take(tweets_num).collect do |tweet|
    
    # Skip if we generated a haiku this search.
    next if generated_haiku
    next if sj.scorecard(tweet.text)['discriminatory'] > 0

    @words = []

    t_text = tweet.text.tr('#@$','').dup
    t_name = tweet.user.screen_name.dup

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
      @words = escape_characters_in_string(t_text).split(' ')
      lines = ['', '', '']

      # First line. 5 syllables.
      lines[0] = get_line(5)
      next unless lines[0]

      # Second line. 7 syllables.
      lines[1] = get_line(7)
      next unless lines[1]

      # Third line. 5 syllables.
      lines[2] = get_line(5)
      next unless lines[2]
      puts "Generated Haiku from Tweet ##{tweet.id}!"
      puts lines
      make_image("#{lines[0]}\n#{lines[1]}\n#{lines[2]}\n- @#{t_name}", tweet.id)
      generated_haiku = true
    else
      abort_text = total_syl > 17 ? 'too many' : 'too few'
      puts "Phrase has #{abort_text} syllables (#{total_syl})!"
    end
  end
  timeout_length = generated_haiku ? 300 : 120
  tweet_timeout(timeout_length)
end

def tweet_timeout(wait_time)
  puts "Waiting #{wait_time} seconds before next poll..."
  wait_time.downto(0) do |i|
    sleep 1
  end

  check_tweets(500)
end

check_tweets(500)
