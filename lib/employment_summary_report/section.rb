class Section
  attr_reader :report, :header_content, :number_of_lines

  def initialize(report:, header_content:, number_of_lines:)
    @report = report
    @header_content = header_content
    @number_of_lines = number_of_lines
  end

  def first_line_index
    report.lines.each_with_index.find{|line, i| line.include?(header_content)}.last
  end

  def last_line_index
    first_line_index + number_of_lines
  end

  def lines
    report.lines[first_line_index .. last_line_index]
  end

  private

  # @param [String] line e.g. "New York               34"
  def last_number(line)
    line.split(" ").last.to_i
  end
end
