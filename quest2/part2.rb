require 'bud'

class App
  include Bud

  def initialize(opts={})
    super opts
  end
  
  state do
    table :words, [:word]
    table :prefixes, [:prefix]
    table :chars, [:char, :idx, :line]
    table :symbols, [:idx, :line]
    table :runics, [:word, :idx, :line, :dir]
  end

  bloom :set_up do
    prefixes <= words.flat_map do |w|
      (0...w.word.length).to_a.map{|i| [w.word[0...i]]}
    end
  end

  bloom :step do
    runics <= (chars * words).pairs(:char => :word).flat_map do |c, w|
      [[c.char, c.idx + 1, c.line, 1],[c.char, c.idx - 1, c.line, -1]]
    end
    runics <= (chars * prefixes).pairs(:char => :prefix).flat_map do |c, p|
      [[c.char, c.idx + 1, c.line, 1],[c.char, c.idx - 1, c.line, -1]]
    end
    runics <= (runics * prefixes * chars).combos(runics.word => prefixes.prefix, runics.idx => chars.idx, runics.line => chars.line) do |r, p, c|
      [r.word + c.char, c.idx + r.dir, r.line, r.dir]
    end
  end

  bloom :do_count do
    symbols <= (runics * words).matches.flat_map do |r,w|
      r.word.chars.each_with_index.map {|c, i| [r.idx - (r.word.length - i) * r.dir, r.line]}
    end
    stdio <~ symbols.group([], count).inspected
  end
end

app = App.new(:stdin => $stdin)
app.words <+ ARGF.readline.chomp[/WORDS:(.*)/, 1].split(',').map{|w| [w]}
ARGF.readline
app.chars <+ ARGF.each_with_index.flat_map do |l, j|
  l.chomp.chars.each_with_index.map do |c, i|
    [c, i, j]
  end
end
app.tick
