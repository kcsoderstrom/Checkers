# Should we really have different names for all these errors?
# I don't know.

module CheckersErrors

  class WrongColor < ArgumentError
  end
  class EmptySquare < ArgumentError
  end
  class IllegalMove < ArgumentError
  end
  class SuicideError < ArgumentError
  end

  def raise_move_errors(start, end_pos, color)
    raise WrongColor unless self[start].color == color
    raise EmptySquare if self[start].nil?
    raise IllegalMove unless self[start].moves.include?(start)

    unless self[end_pos].nil?
      raise SuicideError if self[start].color == self[middle(start, end_pos)].color
    end

  end

end