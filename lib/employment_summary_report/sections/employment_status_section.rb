require_relative "../section"

class EmploymentStatusSection < Section
  class EmploymentStatusTotalsError < StandardError ; end
  class EmployedNonemployedTotalsError < StandardError ; end

  EMPLOYMENT_STATUSES = [
    "Employed - Bar Passage Required",
    "Employed - J.D. Advantage",
    "Employed - Professional Position",
    "Employed - Non-Professional Position",
    "Employed - Law School/University Funded",
    "Employed - Undeterminable",
    "Pursuing Graduate Degree Full Time",
    "Unemployed - Start Date Deferred",
    "Unemployed - Not Seeking",
    "Unemployed - Seeking",
    "Employment Status Unknown",
  ]

  def initialize(report)
    super({
      :report => report,
      :header_content => "EMPLOYMENT STATUS",
      :number_of_lines => EMPLOYMENT_STATUSES.count + 1 + 1
    })
  end

  def results
    counts = []

    EMPLOYMENT_STATUSES.map do |status|
      line = lines.find{|line| line.include?(status) }
      number = last_number(line)
      counts << {status: status, count: number}
    end

    calculated_total_graduates = counts.map{|h| h[:count] }.reduce{|sum, x| sum + x}
    total_graduates = last_number(lines.last)
    raise EmploymentStatusTotalsError unless calculated_total_graduates == total_graduates

    employed_statuses = EMPLOYMENT_STATUSES.select{|status| status.include?("Employed - ")}
    nonemployed_statuses = EMPLOYMENT_STATUSES.select{|status| !status.include?("Employed - ")}
    employed_count = counts.select{|h| employed_statuses.include?(h[:status]) }.map{|h| h[:count] }.reduce{|sum, x| sum + x}
    nonemployed_count = counts.select{|h| nonemployed_statuses.include?(h[:status]) }.map{|h| h[:count] }.reduce{|sum, x| sum + x}
    raise EmployedNonemployedTotalsError if employed_count + nonemployed_count != total_graduates

    return counts
  end
end
