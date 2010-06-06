require "sudoku"
require "test/unit"

class SudokuTest < Test::Unit::TestCase
  
  def test_row_elimination
    puzzle_input = [
      [1,2,3,4,5,6,7,8,nil],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
      [],
    ]
    
    puzzle = Puzzle.new puzzle_input
    puzzle.eliminate

    assert_equal 9, puzzle.cells[0][8].value
  end

  def test_column_elimination
    puzzle_input = [
      [1],
      [2],
      [3],
      [4],
      [5],
      [6],
      [7],
      [8],
      [],
    ]
    
    puzzle = Puzzle.new puzzle_input
    puzzle.eliminate

    assert_equal 9, puzzle.cells[8][0].value
  end

  def test_square_elimination
    puzzle_input = [
      [1,2,3],
      [4,5,6],
      [7,8],
      [],
      [],
      [],
      [],
      [],
      [],
    ]
    
    puzzle = Puzzle.new puzzle_input
    puzzle.eliminate

    assert_equal 9, puzzle.cells[2][2].value
  end

  def test_combining_constraints
    puzzle_input = [
      [1,2,nil,4,5,6,7,8],      # 0,8 can be 3 or 9
      [nil,nil,nil,nil,nil,nil,nil,nil,9], # but 1,8 is 9 => 0,8 = 3
      [],
      [],
      [],
      [],
      [],
      [],
      [],
    ]
    
    puzzle = Puzzle.new puzzle_input
    puzzle.eliminate
    assert_equal 3, puzzle.cells[0][8].value

    # 1,8 is 9 => 0,8 = 3
    puzzle.eliminate
    # => 0,2 = 9
    assert_equal 9, puzzle.cells[0][2].value
  end

  def test_inferring_constraints
    puzzle_input = [
      [nil,nil,nil,  nil,8],
      [],
      [],
      [1,3,2,  7],
      [5,8,9,  4,3,nil,       nil,7,nil],
      [4,6,7,  nil,nil,nil,  5,3,nil],
      [],
      [3,7,1,nil,nil,nil,      nil,nil,8],
      [nil,nil,nil,  8],
    ]
    # 3,5 & 5,5 could be 8 (other cells in sq(1,1) can't be due to
    # row/column elimination. if (3,5) == 8 then (5,8) == 8, but this
    # conflicts with (7,8). Therefore (5,5) == 8
    
    puzzle = Puzzle.new puzzle_input
    puzzle.eliminate
    assert_equal 8, puzzle.cells[5][5].value
  end


end
