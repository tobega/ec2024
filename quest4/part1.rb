require 'bud'

class App
  include Bud

  def initialize(opts={})
    super opts
  end
  
  state do
    table :nails, [:pos] => [:height]
    lmin :lowest
  end

  bloom :hammer do
    lowest <= nails {|n| n.height}
    temp :strikes <= nails {|n| [n.pos, n.height - lowest.reveal]}
    stdio <~ strikes.group([], sum(:height)).inspected
  end
end

app = App.new(:stdin => $stdin)
app.nails <+ ARGF.each_with_index.map do |l, j|
  [j, l.chomp.to_i]
end
app.tick
