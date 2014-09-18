#basic cursor implementation

class Cursor

  attr_reader :row, :col, :width, :height

  def initialize(width = 8, height = 8)
    @width = width
    @height = height
    @row = 0
    @col = 0
  end

  def pos
    [self.row, self.col]
  end

  def left
    @col = (col - 1) % self.width
  end

  def right
    @col = (col + 1) % self.width
  end

  def up
    @row = (row - 1) % self.height
  end

  def down
    @row = (row + 1) % self.height
  end

  def scroll(sym)
    case sym
    when :w
      up
      left
    when :e
      up
      right
    when :s
      down
      left
    when :d
      down
      right
    end
  end

end
