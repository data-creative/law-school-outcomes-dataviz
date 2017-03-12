require_relative "../section"

class EmploymentLocationSection < Section
  LOCATION_TYPES = [
    "State - Largest Employment",
    "State - 2nd Largest Employment",
    "State - 3rd Largest Employment",
    "Employed in Foreign Countries"
  ]
  STATE_TYPES = LOCATION_TYPES.select{|location_type| location_type.include?("State - ")}
  FOREIGN_TYPE = "Employed in Foreign Countries"

  def initialize(report)
    super({
      :report => report,
      :header_content => "EMPLOYMENT LOCATION",
      :number_of_lines => LOCATION_TYPES.count + 1 # includes header line
    })
  end

  def results
    counts = []

    STATE_TYPES.each do |state_type|
      line = lines.find{|line| line.include?(state_type) }
      state_and_count = line.gsub(state_type,"").strip.split("    ").select{|str| !str.empty?}.map{|str| str.strip }
      counts << {type: state_type, location: state_and_count.first, count: state_and_count.last}
    end

    foreign_line = lines.find{|line| line.include?(FOREIGN_TYPE) }
    foreign_count = last_number(foreign_line)
    counts << {type: FOREIGN_TYPE, location: FOREIGN_TYPE, count: foreign_count}

    return counts
  end
end
