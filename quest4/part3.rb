require 'bud'

class App
  include Bud

  def initialize(opts={})
    super opts
  end
  
  state do
    table :nails, [:pos, :iter] => [:height]
    table :pairings, [:pos, :iter, :pair_id] => [:height]
    table :switches, [:pos, :iter] => [:height]
    table :disordered, [:iter]
    table :unsorted, [:pos, :iter] => [:height]
  end

  bloom :do_sort do
    pairings <= nails do |n|
      base = (n.pos - n.iter % 2)
      [n.pos, n.iter, base - base % 2, n.height]
    end
    switches <= (pairings * pairings).pairs(:pair_id => :pair_id, :iter => :iter).flat_map do |p1, p2|
      if p1.pos < p2.pos && p1.height > p2.height
        [[p1.pos, p1.iter, p2.height], [p2.pos, p2.iter, p1.height]]
      end
    end
    disordered <= switches {|s| [s.iter]}
    unsorted <= (disordered * nails).matches {|d, n| n}
    nails <= (switches * unsorted).outer(:pos => :pos, :iter => :iter) do |s,u|
      if s.pos
        [s.pos, s.iter + 1, s.height]
      else
        [u.pos, u.iter + 1, u.height]
      end
    end
  end

  bloom :hammer do
    stdio <~ nails.inspected
  end
end

app = App.new(:stdin => $stdin)
app.nails <+ ARGF.each_with_index.map do |l, j|
  [j, 0, l.chomp.to_i]
end
app.tick
