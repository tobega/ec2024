require 'bud'

class App
  include Bud

  def initialize(part, opts={})
    super opts
    @part = part
  end
  
  state do
    table :chars, [:char, :idx]
    lmax :potions
  end

  bloom :count_potions do
    potions <= chars.reduce([0]) do |count, c|
      case c.char
      when 'B'
        [count[0] + 1]
      when 'C'
        [count[0] + 3]
      else
        count
      end
    end
    stdio <~ [[potions.reveal]]
  end
end

app = App.new(2, :stdin => $stdin)
line = ARGF.readline.chomp.chars
app.chars <+ line.each_with_index.map do |c, i|
  [line[i], i]
end
app.tick
