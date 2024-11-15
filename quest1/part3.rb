require 'bud'

class App
  include Bud

  def initialize(part, opts={})
    super opts
    @part = part
  end
  
  state do
    table :chars, [:char, :idx]
    table :real_chars, [:char, :idx, :grouping]
    table :potion_map, [:char] => [:no_of_potions]
    table :counts, [:char] => [:occ]
    table :potions
    table :base_count, [:val]
    table :join_count, [:val]
  end

  bloom :count_potions do
    potion_map <= [['A', 0], ['B', 1], ['C', 3], ['D', 5]]
    real_chars <= chars do |c|
      if c.char != 'x'
        [c.char, c.idx, c.idx - c.idx % 3]
      end
    end
    counts <= real_chars.group([:char], count)
    potions <= (counts * potion_map).matches {|c, p| [c.char, c.occ * p.no_of_potions]}
    base_count <= potions.group([], sum(:val))
    temp :joins <= (real_chars * real_chars).pairs(:grouping => :grouping) {|o, r| [o.idx, r.idx] unless o.idx == r.idx}
    join_count <= joins.group([], count)
    stdio <~ (base_count * join_count).pairs {|b, j| [b.val + j.val]}
  end
end

app = App.new(2, :stdin => $stdin)
line = ARGF.readline.chomp.chars
app.chars <+ line.each_with_index.map do |c, i|
  [line[i], i]
end
app.tick
