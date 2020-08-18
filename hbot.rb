require 'syllabize'
require 'rmagick'
include Magick

def addt
  img = ImageList.new('Your image path eg.public/computer-cat.jpg')
  txt = Draw.new
  img.annotate(txt, 0,0,0,0, "The text you want to add in the image") {
    txt.gravity = Magick::SouthGravity
    txt.pointsize = 25
    txt.stroke = '#000000'
    txt.fill = '#ffffff'
    txt.font_weight = Magick::BoldWeight
  }

  img.format = 'jpeg'
  send_data img.to_blob,
            :stream => 'false',
            :filename => 'test.jpg',
            :type => 'image/jpeg',
            :disposition => 'inline'
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
else
  abort_text = total_syl > 17 ? 'too many' : 'too few'
  abort "Phrase has #{abort_text} syllables (#{total_syl})!"
end