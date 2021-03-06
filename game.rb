require 'yaml'
require_relative 'board'
require_relative 'title_screen'
require_relative 'cursor_screen'

class Game

  include CursorScreen

  attr_reader :title_screen, :board
  attr_writer :board

  def initialize(board = Board.new, title_screen = TitleScreen.new(board))
    @board = board
    @title_screen = title_screen
    @turn = :red
  end

  def mode_hash
    {:board_mode => self.board,
      :title_mode => self.title_screen }
  end

  def options       #TODO: timer should be paused on options screen
    loop do
      clear_screen
      title_screen.display
      process_action(get_chr, :title_mode)
    end
  end

  def play

    until won?
      board.clock.change_time(@turn)
      self.board.end_of_turn = false
      board.select_only_legal_piece(@turn)
      until self.board.end_of_turn
        play_turn
      end
      swap_turns
    end

    end_game
  end

  def play_turn
    clear_screen
    board.display(@turn)
    process_action(get_chr, :board_mode)
    board.clock.tick(@turn)
  end

  def end_game
    swap_turns
    clear_screen
    board.display(@turn)
    puts "#{@turn.to_s.capitalize} won!"
    play_again
  end

  def play_again
    puts "Would you like to play again?"
    print '≽ '
    reply = gets.chomp[0].downcase
    if reply == 'y'
      new_game = Game.new
      new_game.play
    else
      puts "Oh OK that's cool. Thanks for playing I guess."
    end
  end

  def won?    #awful horrible no
    return true if self.board.pieces(:black).empty?
    return true if self.board.pieces(:red).empty?
    return true if self.board.pieces(:red).all? { |p| p.valid_moves.empty? }
    return true if self.board.pieces(:black).all? { |p| p.valid_moves.empty? }
  end

  def swap_turns
    @turn == :red ? @turn = :black : @turn = :red
  end

  def process_action(chr, mode)

    old_mode = mode
    new_mode = mode_hash[mode].cursor_move(chr.to_sym, @turn)

    unless new_mode == old_mode   # don't restart if the mode didn't change
      mode = new_mode
      self.play if mode == :board_mode
      self.options if mode == :title_mode
    end
  end

end