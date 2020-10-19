# frozen_string_literal: true

require 'syllabize'
require 'rubygems'
require 'mini_magick'
require 'twitter'
require 'swearjar'
require 'yaml'

# Settings.
# TODO: Build a YML with settings
@settings = {
  'img_path': './img/generated',
  'base_img_path': './img'
}

def escape_characters_in_string(string)
  pattern = %r{(\'|\"|\.|\*|/|\-|\\)}
  # Trying to take the currently found match and add a \ before it I have no idea how to do that).
  string.gsub(pattern) { |match| '\\' + match }
end

def make_image(text, id)
  # Picks a base image. Base images are in img/* and labeled as base_*
  base_img_list = Dir["#{@settings[:base_img_path]}/base_*.jpg"]
  base_img = base_img_list.sample
  base_img_number = File.basename(base_img, '.*').gsub('base_', '')

  # Changing settings based on image so they look nice.
  base_img_settings = YAML.safe_load(File.read('base_img_settings.yml'))

  puts "Building image using #{base_img}."

  img = MiniMagick::Image.open(base_img)

  img.combine_options do |c|
    c.gravity base_img_settings[:"#{base_img_number}"][:gravity]
    c.pointsize base_img_settings[:"#{base_img_number}"][:pointsize]
    c.stroke base_img_settings[:"#{base_img_number}"][:stroke]
    c.draw "text 50,30 '#{text}'"
    c.font './Mansalva-Regular.ttf'
    c.strokewidth 2
    c.fill(base_img_settings[:"#{base_img_number}"][:fill])
  end

  img.write("#{@settings[:img_path]}/#{id}.jpg")

  puts 'Image written.'
end

def get_line(line_length)
  line = ''
  line_syl = 0
  while line_syl < line_length
    line_syl += @words[0].downcase.gsub(/[^a-z0-9\s]/i, '').chomp.count_syllables
    fixed_word = @words[0].gsub(/\\\./, '.')
    line += if line == ''
              fixed_word
            else
              " #{fixed_word}"
            end
    # Removes the word from the list entirely
    @words.reject!.with_index { |_v, i| i.zero? }
  end
  if line.count_syllables > line_length
    puts "Unable to make clean #{line_length}-syllable sentence (#{line})"
    return false
  end
  line
end

def check_tweets(tweets_num)
  puts "Checking #{tweets_num} latest tweets..."

  sj = Swearjar.default

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

    # Skip if it has discriminatory language.
    scorecard = sj.scorecard(tweet.text)
    next if scorecard.key?('discriminatory') && (scorecard['discriminatory']).positive?

    @words = []

    # Setting encoding options to remove tweets with garbage characters
    encoding_options = {
      invalid: :replace, # Replace invalid byte sequences
      undef: :replace, # Replace anything not defined in ASCII
      replace: '', # Use a blank for those replacements
      universal_newline: true # Always break lines with \n
    }

    t_text = tweet.text.tr('#@$', '').encode(Encoding.find('ASCII'), encoding_options).dup
    t_name = tweet.user.screen_name.dup

    # this removes @ and # entries
    # t_text.gsub!(/\B[@#]\S+\b/, '')
    t_text.gsub!(/#{URI::DEFAULT_PARSER.make_regexp}/, '')
    if File.exist?("#{@settings[:img_path]}/#{tweet.id}.jpg")
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

      bylines_arr = File.readlines('./by_lines')
      byline = bylines_arr.sample.chomp.gsub('%NAME%', t_name)
      puts "Generated Haiku from Tweet ##{tweet.id}!\n"
      puts byline
      puts lines
      puts "- #{t_name}"
      make_image("#{lines[0]}\n#{lines[1]}\n#{lines[2]}\n- @#{t_name}", tweet.id)
      posted_tweet = client.update_with_media(byline, File.new("#{@settings[:img_path]}/#{tweet.id}.jpg"))
      puts "Tweet #{posted_tweet.id} posted: #{posted_tweet.url}"
      generated_haiku = true
    else
      abort_text = total_syl > 17 ? 'too many' : 'too few'
      puts "Phrase has #{abort_text} syllables (#{total_syl})!"
    end
  end
  timeout_length = generated_haiku ? 3600 : 120
  tweet_timeout(timeout_length)
end

def tweet_timeout(wait_time)
  puts "Waiting #{wait_time} seconds before next poll..."
  wait_time.downto(0) do |_i|
    sleep 1
  end

  begin
    check_tweets(500)
  rescue StandardError => e
    abort "Error: #{e.message}"
  end
end

begin
  check_tweets(500)
rescue StandardError => e
  abort "Error: #{e.message}"
end
