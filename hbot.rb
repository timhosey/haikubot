require 'syllabize'
require 'rubygems'
require 'mini_magick'

def make_image(text)
  img = MiniMagick::Image.open('img/base.jpg')

  img.combine_options do |c|
    c.gravity 'East'
    c.draw "text 100,10 '#{text}'"
    c.font './JapaneseTourist.ttf'
    c.pointsize 100
    # c.stroke 'white'
    # c.strokewidth 1
    c.fill('#000000')
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