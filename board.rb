require_relative "game"
require_relative 'piece' #might not need this wedk
require_relative 'cursor'
require_relative 'chars_array'
require_relative 'plane_like'
require_relative 'chess_clock'
require_relative 'chess_errors'
require_relative 'symbol'
require 'colorize'

class Board

  include PlaneLike
  include ChessErrors

  COLORS = [:white, :black]

  attr_reader :cursor, :prev_pos, :clock, :upgrade_cursor
  attr_accessor :end_of_turn, :takens

  def initialize
    @rows = Array.new(8) { Array.new(8) }
    place_pieces
    @cursor = Cursor.new
    @prev_pos = nil
    @end_of_turn = false
    @clock = ChessClock.new
    @takens = [[],[]]
  end

  def click(turn)
    pos = cursor.pos

    if self.prev_pos.nil?
      self.prev_pos = pos unless self[pos].nil? || self[pos].color != turn
    else
      begin
        move(self.prev_pos, pos, turn)
        self.end_of_turn = true
      rescue ArgumentError
        self.prev_pos = nil   # clicked in a bad spot so resets
      end
      self.prev_pos = nil
    end
  end

  def opposite(color)
    color == COLORS[0] ? COLORS[1] : COLORS[0]
  end

  def move(start, end_pos, color)       # GETTING A FUNNY YOU-CAN-JUMP ERROR NOO
    raise_move_errors(start, end_pos, color)

    if jump?(start, end_pos)
      taken_piece_pos = middle(start, end_pos)
      taken_piece = self[taken_piece_pos]
      self[taken_piece_pos] = nil
      unless taken_piece.nil?
        (taken_piece.color == :white ? takens[0] : takens[1]) << taken_piece
      end
      taken_piece.move(nil)   #kinda hacky
    else
      unless all_pieces(color).reject { |piece| piece.jump_moves.empty? }.empty?
        raise ArgumentError.new("You have to jump if you can.")
      end
    end

    self[start], self[end_pos] = nil, self[start]

    moved_piece = self[end_pos]
    moved_piece.move(end_pos)      #this seems stupid

    unless moved_piece.is_a?(King) || !moved_piece.at_end?
      moved_piece = King.new(self, moved_piece.color, moved_piece.pos)
    end

    if jump?(start, end_pos)
      unless moved_piece.jump_moves.empty?
        raise ArgumentError.new("Go again") # hacky?
      end
    end

  end

  def jump?(pos1, pos2)
    (pos1[0] - pos2[0]).abs == 2 && (pos1[1] - pos2[1]).abs == 2
  end

  def cursor_move(sym,turn)
    if sym == :r
      self.click(turn)
    elsif sym == :o
      return :title_mode
    else
      cursor.cursor_move(sym)
    end
    :board_mode
  end

  def dup
    duped = Board.new
    8.times do |y|
      rows[y].each_with_index do |piece, x|
        duped[[y,x]] = nil                   # Have to do this bc place_pieces
        unless self[[y,x]].nil?
          duped[[y,x]] = piece.class.new(duped,piece.color,[y, x])
        end
      end
    end
    duped
  end

  def all_pieces(color)
    self.rows.flatten.compact.select { |piece| piece.color == color }
  end

  def display(turn)
    puts render(turn)
  end

  def middle(pos1, pos2)
    [(pos1[0] + pos2[0]) / 2, (pos1[1] + pos2[1]) / 2]
  end



  protected
  attr_writer :prev_pos

  private
  attr_accessor :mode
  def taken_pieces(color)
    color == :white ? takens[0] : takens[1]
  end

  def place_pieces      # kinda illegible
    8.times do |col|
      rows[col % 2][col] = Piece.new(self, :black, [col % 2, col])
      rows[2][(2 * col) % 8] = Piece.new(self, :black, [2, (2 * col) % 8])
      rows[6 + (col % 2)][col] = Piece.new(self, :white, [6 + (col % 2), col])
      rows[5][(2 * col +1) % 8] = Piece.new(self, :white, [5, (2 * col + 1) % 8])
    end
  end

  def render(turn)
    characters_array = CharsArray.new(self, turn).characters_array(self.rows)
    white_chars = CharsArray.new(self, turn).convert_to_chars(takens[0])
    black_chars = CharsArray.new(self, turn).convert_to_chars(takens[1])
    white_chars.sort!
    black_chars.sort!       #should probably sort the pieces really

    str = ''
    str << white_chars.drop(8).join << "\n"
    str << white_chars.take(8).join << "\n"
    characters_array.each do |row|
      row.each { |char| str << char }
      str << "\n"
    end
    str << black_chars.take(8).join << "\n"
    str << black_chars.drop(8).join << "\n"

    str << "White Current Time: #{clock.convert_times[0]} \t" <<
           "White Total Time: #{clock.convert_times[1]}\n" <<
           "Black Current Time: #{clock.convert_times[2]} \t" <<
           "Black Total Time: #{clock.convert_times[3]}"
    str

  end

end