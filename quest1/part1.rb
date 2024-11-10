require 'bud'

class App
  include Bud

  def initialize(part, opts={})
    super opts
    @part = part
  end
  
  state do
    table :chars, [:char, :idx]
    table :potion_map, [:char] => [:no_of_potions]
    table :counts, [:char] => [:occ]
    table :potions
  end

  bloom :count_potions do
    potion_map <= [['A', 0], ['B', 1], ['C', 3]]
    counts <= chars.group([:char], count)
    potions <= (counts * potion_map).matches {|c, p| [c.char, c.occ * p.no_of_potions]}
    stdio <~ potions.group([], sum(:val))
  end
end

app = App.new(2, :stdin => $stdin)
line = ARGF.readline.chomp.chars
app.chars <+ line.each_with_index.map do |c, i|
  [line[i], i]
end
app.tick
