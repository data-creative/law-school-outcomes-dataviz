require_relative "../section"

class EmploymentTypeSection < Section
  class EmployedGraduatesTotalsError < StandardError ; end

  EMPLOYMENT_TYPES = [
    {label:"Law Firms", sizes:["Solo", "2 - 10", "11 - 25", "26 - 50", "51 - 100", "101 - 250", "251 - 500", "501 +", "Unknown Size"]},
    {label:"Business & Industry"},
    {label:"Government"},
    {label:"Pub. Int."},
    {label:"Clerkships - Federal"},
    {label:"Clerkships - State & Local"},
    {label:"Clerkships - Other"},
    {label:"Education"},
    {label:"Employer Type Unknown"}
  ]
  LAW_FIRM_SIZES = EMPLOYMENT_TYPES.find{|h| h[:label] == "Law Firms"}[:sizes]
  NON_LAW_FIRM_TYPES = EMPLOYMENT_TYPES.reject{|h| h[:label] == "Law Firms"}.map{|h| h[:label]}

  def initialize(report)
    super({
      :report => report,
      :header_content => "EMPLOYMENT TYPE",
      :number_of_lines => EMPLOYMENT_TYPES.count + LAW_FIRM_SIZES.count + 1 + 1
    })
  end

  def results
    counts = []

    LAW_FIRM_SIZES.each do |size|
      line = lines.find{|line| line.include?(size) }
      number = last_number(line)
      counts << {type: "Law Firms (#{size})", count: number}
    end

    NON_LAW_FIRM_TYPES.each do |type|
      line = lines.find{|line| line.include?(type) }
      number = last_number(line)
      counts << {type: type, count: number}
    end

    total_employed_graduates = last_number(lines.last)
    calculated_total_employed_graduates = counts.map{|h| h[:count] }.reduce{|sum, x| sum + x}
    raise EmployedGraduatesTotalsError if total_employed_graduates != calculated_total_employed_graduates

    return counts
  end
end
