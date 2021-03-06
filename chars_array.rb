require_relative 'board'
require_relative 'piece'
require_relative 'plane_like'

class CharsArray

  include PlaneLike

  BG_COLORS = [:light_red, :light_black]
  BG_SWAP = { BG_COLORS[0] => BG_COLORS[1],
              BG_COLORS[1] => BG_COLORS[0] }

  attr_accessor :board, :turn

  def initialize(board, turn)
    @rows = Array.new(8) { Array.new(8) }
    @board = board
    @turn = turn
    @bg_color = :light_red
    convert_without_highlight
    highlight_squares
  end

  def highlight_squares
    unless board.selected_piece.nil?
      hold_highlight_on_selected_piece
      highlight_available_moves(board.selected_piece)
    end
    highlight_cursor
  end

  def hold_highlight_on_selected_piece
    pos = board.prev_pos
    self[pos] = self[pos].colorize(:background => :light_white)
  end

  def highlight_available_moves(selected_piece)
    selected_piece.valid_moves.each do |move|
      self[move] = self[move].colorize(:background => :white)
    end
  end

  def highlight_cursor
    pos = board.cursor.pos
    self[pos] = self[pos].colorize(:background => :light_white)
  end

  def convert_without_highlight
    self.rows.count.times do |y|
      self.rows[y] = board.rows[y].render
      self.rows[y].each_with_index do |char, x|
        self[[y, x]] = char.colorize( :background => background_color_swap )
      end

      background_color_swap
    end
  end

  def background_color_swap
    @bg_color =  BG_SWAP[@bg_color]
  end

end

class Array
  def render
    self.map { |piece| piece.render }
  end
end
