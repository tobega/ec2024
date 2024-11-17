require 'bud'

class App
  include Bud

  def initialize(opts={})
    super opts
  end
  
  state do
    table :areas, [:x, :y, :depth]
    table :depths, [:x, :y, :depth]
  end

  bloom :dig do
    temp :slope_s <= areas {|a| [a.x, a.y + 1, a.depth]}
    temp :slope_n <= areas {|a| [a.x, a.y - 1, a.depth]}
    temp :slope_w <= areas {|a| [a.x - 1, a.y, a.depth]}
    temp :slope_e <= areas {|a| [a.x + 1, a.y, a.depth]}
    areas <= (slope_s * slope_n * slope_w * slope_e * areas).matches {|s,n,w,e,a| [a.x, a.y, a.depth + 1]}
  end

  bloom :do_count do
    depths <= areas.group([:x, :y], max(:depth))
    stdio <~ depths.group([], sum(:depth)).inspected
  end
end

app = App.new(:stdin => $stdin)
app.areas <+ ARGF.each_with_index.flat_map do |l, j|
  l.chomp.chars.each_with_index.map do |c, i|
    if c == '#'
      [i, j, 1]
    end
  end
end
app.tick
