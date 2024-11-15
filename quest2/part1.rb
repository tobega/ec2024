require 'bud'

class App
  include Bud

  def initialize(opts={})
    super opts
  end
  
  state do
    table :words, [:word]
    table :prefixes, [:prefix]
    table :chars, [:char, :idx]
    table :runics, [:word, :idx]
  end

  bloom :set_up do
    prefixes <= words.flat_map do |w|
      (0...w.word.length).to_a.map{|i| [w.word[0...i]]}
    end
  end

  bloom :step do
    runics <= (chars * prefixes).pairs(:char => :prefix) {|c, p| [c.char, c.idx + 1]}
    runics <= (runics * prefixes * chars).combos(runics.word => prefixes.prefix, runics.idx => chars.idx) do |r, p, c|
      [r.word + c.char, c.idx + 1]
    end
  end

  bloom :do_count do
    temp :found <= (runics * words).matches {|r, w| r}
    stdio <~ found.group([], count).inspected
  end
end

app = App.new(:stdin => $stdin)
app.words <+ ARGF.readline.chomp[/WORDS:(.*)/, 1].split(',').map{|w| [w]}
ARGF.readline
line = ARGF.readline.chomp.chars
app.chars <+ line.each_with_index.map do |c, i|
  [line[i], i]
end
app.tick
