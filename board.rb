require_relative 'game'
require_relative 'piece'
require_relative 'cursor'
require_relative 'chars_array'
require_relative 'plane_like'
require_relative 'chess_clock'
require_relative 'checkers_errors'
require_relative 'symbol'
require 'colorize'

class Board

  include PlaneLike
  include CheckersErrors

  COLORS = [:red, :black]

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
      rescue CheckersError
        self.prev_pos = nil   # clicked in a bad spot so resets
      end
    end
  end

  def select_only_legal_piece(turn)
    selectables = self.pieces(turn).reject { |piece| piece.jump_moves.empty? }
    if selectables.count == 1
      self.prev_pos = selectables[0].pos
      cursor.pos = prev_pos
    end
  end

  def selected_piece
    self[self.prev_pos] unless self.prev_pos.nil?
  end

  def opposite(color)
    color == COLORS[0] ? COLORS[1] : COLORS[0]
  end

  def take(start, end_pos)
    taken_piece_pos = middle(start, end_pos)
    taken_piece = self[taken_piece_pos]
    self[taken_piece_pos] = nil
    taken_box = ( taken_piece.color == :red ? takens[0] : takens[1] )
    taken_box << taken_piece
  end

  def jump(start, end_pos, color)
    self.take(start, end_pos)

    if self[end_pos].jump_moves.empty?
      self.end_of_turn = true
      self.prev_pos = nil
    else                                # For double-jumps
      self.end_of_turn = false
      self.prev_pos = end_pos
    end
  end

  def slide(start, end_pos, color)
    self.end_of_turn = true
    self.prev_pos = nil     #deselects cursor #probably should rename
  end

  def move(start, end_pos, color)
    raise_move_errors(start, end_pos, color)

    moved_piece = self[start]
    moved_piece.move(end_pos)

    unless moved_piece.is_a?(King) || !moved_piece.at_end?
      moved_piece = King.new(self, moved_piece.color, moved_piece.pos)
    end

    if jump?(start, end_pos)
      jump(start, end_pos, color)
    else
      slide(start, end_pos, color)
    end
  end

  def jump?(pos1, pos2)
    (pos1[0] - pos2[0]).abs == 2 && (pos1[1] - pos2[1]).abs == 2
  end

  def cursor_move(sym,turn)
    if sym == :" "
      self.click(turn)
    elsif sym == :o
      return :title_mode
    else
      cursor.scroll(sym)
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

  def pieces(color)
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
    color == :red ? takens[0] : takens[1]
  end

  def place_pieces      # kinda illegible
    8.times do |col|
      rows[col % 2][col] = Piece.new(self, :black, [col % 2, col])
      rows[2][(2 * col) % 8] = Piece.new(self, :black, [2, (2 * col) % 8])
      rows[6 + (col % 2)][col] = Piece.new(self, :red, [6 + (col % 2), col])
      rows[5][(2 * col +1) % 8] = Piece.new(self, :red, [5, (2 * col + 1) % 8])
    end
  end

  def render(turn)
    characters_array = CharsArray.new(self, turn).rows.map

    white_chars = takens[0].render.sort
    black_chars = takens[1].render.sort

    str = ''
    str << white_chars.drop(8).join << "\n"
    str << white_chars.take(8).join << "\n"
    characters_array.each do |row|
      row.each { |char| str << char }
      str << "\n"
    end
    str << black_chars.take(8).join << "\n"
    str << black_chars.drop(8).join << "\n"

    str << "Red Current Time: #{clock.convert_times[0]} \t" <<
           "Red Total Time: #{clock.convert_times[1]}\n" <<
           "Black Current Time: #{clock.convert_times[2]} \t" <<
           "Black Total Time: #{clock.convert_times[3]}"
    str

  end

end