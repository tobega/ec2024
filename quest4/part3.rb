require 'bud'

class App
  include Bud

  def initialize(opts={})
    super opts
  end
  
  state do
    table :nails, [:pos] => [:height]
    table :median, [:height]
    lmin :level
  end

  bloom :hammer do
    level <= median {|m| m.height}
    temp :strikes <= nails {|n| [n.pos, (n.height - level.reveal).abs]}
    stdio <~ strikes.group([], sum(:height)).inspected
  end
end

app = App.new(:stdin => $stdin)
values = ARGF.map {|l| l.chomp.to_i}.sort
app.nails <+ values.each_with_index.map do |v, j|
  [j, v]
end
app.median <+ [[values[values.length / 2]]]
app.tick
