class CheckersError < ArgumentError
end

module CheckersErrors

  def raise_move_errors(start, end_pos, color)
    raise CheckersError.new("not your color") unless self[start].color == color
    raise CheckersError.new("no piece there") if self[start].nil?
    raise CheckersError.new("illegal location") unless self[start].moves.include?(end_pos)

    unless self[end_pos].nil?
      raise CheckersError.new("can't take your own piece") if self[start].color == self[middle(start, end_pos)].color
    end

    unless jump?(start, end_pos)
      unless self.pieces(color).reject { |piece| piece.jump_moves.empty? }.empty?
        raise CheckersError.new("You have to jump if you can.")
      end
    end

  end

end
