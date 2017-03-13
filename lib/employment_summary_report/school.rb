class School
  attr_reader :report, :number_of_lines

  def initialize(report)
    @report = report
    @number_of_lines = 5
  end

  def lines
    report.lines.first(number_of_lines)
  end

  def info
    return {
      name: lines.first, #.upcase,
      address:{
        street: lines[1].strip, #.upcase,
        city: city_and_state_and_zip.split(", ").first,
        state: state_and_zip.split(" ").first,
        zip: state_and_zip.split(" ").last
      },
      phone: lines[2].split("Phone : ").last.strip,
      website: lines[4].split("Website : ").last.strip
    }
  end

  private

  def city_and_state_and_zip
    lines[3].strip #.upcase
  end

  def state_and_zip
    city_and_state_and_zip.split(", ").last
  end
end
