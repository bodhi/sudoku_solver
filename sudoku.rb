module Debug
  def debug str
    puts str if @verbose
  end

  def verbose!
    @verbose = true
  end
end

class Cell
  include Debug

  attr_accessor :value
  attr_accessor :possibilities

  def initialize value
    if value.is_a? Cell
      self.value = value.value
      self.possibilities = value.possibilities.dup
    else
      self.value = value
      self.possibilities = value ? [] : (1..9).to_a
    end
  end

  def can_be values
    debug "can be #{values.inspect} from #{self.possibilities.inspect}"
    self.possibilities = possibilities & values
    debug "now can be #{self.possibilities.inspect}"

    if possibilities.size == 1
      self.value = possibilities.first
    end
  end

  def others_can_be values
    leftover = possibilities - values
    if leftover.size == 1
      self.value = leftover.first
    end
  end

  def value= value
    @value = value
    self.possibilities = []
  end

  def to_s
    value ? value.to_s : " "
  end

end


# Constraint to be implemented:
#
# For puzzle
#
# 125|739|8  
# 694|281|537
# 873| 5 |  9
# -----------
#  5 |3 8|   
#   7|   |38 
# 3  | 9 |4  
# -----------
#  61|8 3| 52
#    |5  |  3
# 532|9  |6 8
#
# the top right corner value (0,8) can be determined to be 4. By row
# elimination on row 0, it can either be 4 or 6 (along with 0,7);
# However if you examine square (1,2) (middle-right), it can be seen
# that 4 cannot be in cells (3-5,8) as it is already in cell
# (5,6). Therefore the only place that 4 can appear in column 8 is in
# cell (0,8)
#
# For puzzle
#
# 7 3| 84|6  
# 294| 7 |  3
# 6 8|3  | 47
# -----------
# 132|7  |   
# 589|43 | 7 
# 467|   |53 
# -----------
# 82 |  7|31 
# 371|   | 98
# 94 |813|7  
#
# cell (5,5) must be 8. Via row/column elimination, either (3,5) or
# (5,5) must be 8, as none of the other cells in square (1,1) can
# be. However, if (3,5) is 8, then in square (1,2), (5,8) must be 8, as
# the other cells are eliminated by row elimination on rows 3 & 4. But
# this conflicts with (7,8), therefore (3,5) cannot be 8, resulting in 8
# for (5,5).
class Puzzle
  include Debug

  attr_accessor :cells

  def initialize input
    self.cells = []
    9.times do |row|
      cells[row] = []
      9.times do |col|
        cells[row][col] = Cell.new input[row][col]
      end
    end
  end

  def copy
    copy = self.class.new cells
    copy.verbose! if @verbose
    copy
  end
  
  def solve
    last_filled = 0
    while last_filled < filled
      # try twice, there's a bug that will sometimes skip constrained
      # cells
      last_filled = eliminate
      last_filled = eliminate
    end
    unless solved?
      debug "after elimination:\n#{self}"
      cells.each_with_index do |row, i|
        row.each_with_index do |cell, j|
          if !cell.value
            cell.possibilities.each do |value|
              debug "trying #{value} at #{i},#{j}"
              guess = copy
              guess.cells[i][j].value = value
              guess.solve
              if guess.solved?
                self.cells = guess.cells
                return
              end
              debug "#{value} at #{i},#{j} doesn't work"
            end
          end
        end
      end
    end
  end

  def solved?
    cells.all? { |row| row.all? { |cell| cell.value }}
  end

  def filled
    count = 0
    cells.each { |row| row.each { |cell| count += 1 if cell.value }}
    count
  end

  def eliminate
    # eliminate values set in other areas
    9.times do |row|
      9.times do |col|
        cell = cells[row][col]
        unless cell.value
          values = cell_values(row, col) & row_values(row) & col_values(col)
#          puts "possible values for #{row},#{col} = #{values.inspect}"
          cell.can_be values

          other_possibilities row, col
        end
      end
    end

    filled
  end

  def cell_values row, col
    possible_values square(row,col)
  end

  def square row, col
    n_row = (row / 3) * 3
    n_col = (col / 3) * 3
    
    cells[n_row,3].collect { |c| c[n_col, 3]}.flatten
  end

  def other_possibilities row, col
    cells = square(row,col)
    this = cells.delete self.cells[row][col]
    others = cells.collect {|c| c.possibilities }.flatten.uniq.compact
    this.others_can_be others
  end

  def col_values col
    section = cells.collect { |c| c[col] }.flatten
    possible_values section
  end
  
  def row_values row
    possible_values cells[row]
  end

  def possible_values cells
    set_values = cells.collect { |c| c.value }.compact
    possibilities = cells.collect { |c| c.possibilities }.flatten.uniq
    possibilities - set_values
  end

  def to_s
    s = ""
    9.times do |col|
      9.times do |row|
        s << cells[col][row].to_s
        s << "|" if row % 3 == 2 && row != 8
      end
      s << "\n"      
      s << (("-" * 11) + "\n") if col % 3 == 2
    end
    s
  end

end

class Reader
  attr_accessor :input

  def initialize input_stream = $stdin
    @input = []
    while @input.length < 9
      line = input_stream.readline.chomp
      data = line.split("")
      unless data.length == 9
        puts "Ignoring odd line: '#{line}' #{data.inspect} (#{data.length})"
      else
        data = data.collect {|c| 
          c = c.to_i 
          c if c > 0
        }
        puts data.collect {|c| c.nil? ? "." : c }.join("")
        @input << data
      end
    end
  end

end

if __FILE__ == $0
  puts "Enter puzzle, 1 row per line (values outside 1-9 are treated as blank):"
  reader = Reader.new $stdin
  
  puzzle = Puzzle.new reader.input

  puzzle.verbose!
  
  puzzle.solve
  puts puzzle
end
