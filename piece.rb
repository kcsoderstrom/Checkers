require_relative 'board'
require_relative 'checkers_errors'

class Piece

  COLOR_DIR = { :black => 1, :white => -1 }

  include CheckersErrors
  attr_reader :board, :color, :pos

  def initialize(board = Board.new, color = :white, pos = [0, 0])
    @color = color
    @pos = pos
    @board = board
    @board[pos] = self
    @first_move = true
    @delta = COLOR_DIR[color]
  end

  attr_reader :delta

  def move(new_pos)
    board[self.pos] = nil
    board[new_pos] = self
    self.pos = new_pos
  end

  def moves
    jump_moves + vanilla_moves
  end

  def jump_moves
    moves = []
    y = self.pos[0] + 2 * delta

    [2, -2].each do |d|
      x = self.pos[1] + d
      if on_board?([y, x])
        skipped = board[ board.middle([y,x], self.pos) ]
        unless skipped.nil?
          moves << [y,x] if board[[y, x]].nil? && skipped.color != self.color
        end
      end
    end

    moves
  end

  def vanilla_moves
    moves = []
    y = self.pos[0] + delta

    x = self.pos[1] + 1
    moves << [y,x] if on_board?([y, x]) && board[[y, x]].nil?

    x = self.pos[1] - 1
    moves << [y,x] if on_board?([y, x]) && board[[y, x]].nil?

    moves
  end

  def at_end?
    self.color == :white ? self.pos[0] == 0 : self.pos[0] == 7
  end

  def on_board?(pos)
    pos[0].between?(0,7) && pos[1].between?(0,7)
  end

  def legal_jump_moves      # I don't think I actually need .legal? anymore.
    jump_moves.select { |jump_move| legal?(jump_move) }
  end

  def valid_moves
    return jump_moves unless jump_moves.empty?
    return moves if board.pieces(color).all?{ |piece| piece.jump_moves.empty? }
    []
  end

  def render
    color == :white ? '○' : '●'
  end

  protected
  attr_writer :pos

end

class King < Piece

  def moves
    @delta = -1
    down_moves = super
    @delta = 1
    up_moves = super

    down_moves + up_moves
  end

  def render
    color == :white ? '♕' : '♛'
  end

end

class NilClass
  def render
    ' '
  end
end