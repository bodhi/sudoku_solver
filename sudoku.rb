class Cell
  attr_accessor :value
  attr_accessor :possibilities

  def initialize value
    self.value = value.to_i
    self.possibilities = value ? [] : (1..9).to_a
  end

  def can_be values
#    puts "can be #{values.inspect} from #{self.possibilities.inspect}"
    self.possibilities = possibilities & values
#    puts "now can be #{self.possibilities.inspect}"

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

  def to_i
    value
  end

end

class Puzzle
  attr_accessor :cells

  def initialize input
    self.cells = []
    9.times do |row|
      cells[row] = []
      9.times do |col|
        puts "#{row},#{col} = #{input[row][col]}"
        cells[row][col] = Cell.new input[row][col]
      end
    end
   
  end

  def solve
    last_filled = 0
    while last_filled < filled
      last_filled = filled
      eliminate
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
#    row /= 3
#    row *= 3
#    col /= 3
#    col *= 3
    
#    square = cells[row,3].collect { |c| c[col, 3]}.flatten
    possible_values square(row,col)
  end

  def square row, col
    n_row = row / 3
    n_row *= 3
    n_col = col / 3
    n_col *= 3
    
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