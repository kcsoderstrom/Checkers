require_relative 'board'
require_relative 'piece'
require_relative 'plane_like'

class CharsArray

  include PlaneLike

  WHITE_CHARS = { Piece => '○',
                  King => '♕',
                  NilClass => ' '}

  BLACK_CHARS = { Piece => '●',
                  King => '♛',
                  NilClass => ' '}

  BG_COLORS = [:light_white, :light_black]
  BG_SWAP = { BG_COLORS[0] => BG_COLORS[1],
              BG_COLORS[1] => BG_COLORS[0] }

  attr_accessor :board, :turn

  def initialize(board, turn)
    @rows = Array.new(8) { Array.new(8) }
    @board = board
    @turn = turn
    @bg_color = :light_white
  end

  # Converts the board to characters, then highlights.
  # Don't use this on the taken pieces.
  def characters_array(arr)    # That's a terrible name.
    initial_convert = board_chars(arr)
    highlight_squares(initial_convert)
  end

  def highlight_squares(arr)      #horrible names errywhere
    unless self.board.prev_pos.nil?
      selected_piece = self.board[self.board.prev_pos]
      held_arr = hold_highlight_on_selected_piece(arr)
      high_arr = highlight_available_moves(selected_piece, held_arr)
      highlight_cursor(high_arr)
    else
      highlight_cursor(arr)
    end
  end

  def hold_highlight_on_selected_piece(arr)
    pos = board.prev_pos
    arr[pos[0]][pos[1]] = arr[pos[0]][pos[1]].colorize(:background => :cyan)
    arr
  end

  def highlight_available_moves(selected_piece, arr)
    unless selected_piece.nil? || selected_piece.color != turn
      selected_piece.valid_moves.each do |move|
        arr[move[0]][move[1]] = arr[move[0]][move[1]].colorize(:background => :green)
      end
    end
    arr
  end

  def highlight_cursor(arr)
    pos = board.cursor.pos
    arr[pos[0]][pos[1]] = arr[pos[0]][pos[1]].colorize(:background => :cyan)
    arr
  end


  def board_chars(arr)
    height = arr.count
    width = arr[0].count

    converted = Array.new (height) { Array.new (width) }

    height.times do |y|
      converted[y] = convert_to_chars(arr[y])
      converted[y].each_with_index do |char, x|
        converted[y][x] = char.colorize( :background => background_color_swap )
      end

      background_color_swap
    end
    converted
  end

  def background_color_swap
    @bg_color =  BG_SWAP[@bg_color]
  end

  def convert_to_chars(arr)
    num_pieces = arr.count

    converted = []
    arr.each { |piece| converted << piece.render }
    converted
  end

end
