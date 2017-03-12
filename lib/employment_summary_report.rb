require "open-uri"
require "pdf-reader"
require "pry"

class EmploymentSummaryReport
  attr_reader :url, :lines

  def initialize(url)
    @url = url
    @lines = read_lines
  end

  def year
    @year ||= lines[5].gsub("EMPLOYMENT SUMMARY FOR ","").gsub(" GRADUATES","").to_i
  end

  #
  # SCHOOL
  #

  def school_lines
    lines.first(5)
  end

  def school
    city_state_zip = school_lines[3].strip.upcase
    state_zip = city_state_zip.split(", ").last

    return {
      name: school_lines.first.upcase,
      address:{
        street: school_lines[1].strip.upcase,
        city: city_state_zip.split(", ").first,
        state: state_zip.split(" ").first,
        zip: state_zip.split(" ").last
      },
      phone: school_lines[2].split("Phone : ").last.strip,
      website: school_lines[4].split("Website : ").last.strip
    }
  end

  #
  # EMPLOYMENT STATUS
  #

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

  def employment_status_lines
    status_section = { # header line is followed by a line per employment status, followed by a line for "Total Graduates"
      first_line_index: lines.each_with_index.find{|line, i| line.include?("EMPLOYMENT STATUS")}.last,
      number_of_lines: EMPLOYMENT_STATUSES.count + 1 + 1 # includes header line and totals line
    }
    status_section[:last_line_index] = status_section[:first_line_index] + status_section[:number_of_lines]

    return lines[status_section[:first_line_index] .. status_section[:last_line_index]]
  end

  def employment_status
    counts = EMPLOYMENT_STATUSES.map do |status|
      line = employment_status_lines.find{|line| line.include?(status) }
      number = last_number(line)
      {status: status, count: number}
    end

    calculated_total_graduates = counts.map{|h| h[:count] }.reduce{|sum, x| sum + x}
    total_graduates = last_number(employment_status_lines.last)
    raise EmploymentStatusTotalsError unless calculated_total_graduates == total_graduates

    employed_statuses = EMPLOYMENT_STATUSES.select{|status| status.include?("Employed - ")}
    nonemployed_statuses = EMPLOYMENT_STATUSES.select{|status| !status.include?("Employed - ")}
    employed_count = counts.select{|h| employed_statuses.include?(h[:status]) }.map{|h| h[:count] }.reduce{|sum, x| sum + x}
    nonemployed_count = counts.select{|h| nonemployed_statuses.include?(h[:status]) }.map{|h| h[:count] }.reduce{|sum, x| sum + x}
    raise EmployedNonemployedTotalsError if employed_count + nonemployed_count != total_graduates

    return counts
  end



















  private

  def io
    #io = open(url)

    # test using local file for now:
    dir = File.expand_path("../../reports/2015/", __FILE__)
    report_names = Dir.entries(dir).reject{|file_name| [".","..",".gitkeep"].include?(file_name) }
    report_name = report_names.sample
    io = File.join(dir, report_name)
  end

  def read_lines
    reader = PDF::Reader.new(io)
    lines = reader.pages.first.text.split("\n")
    lines.select!{|line| line.size > 0 }
    lines.map!{|line| line.strip }
    raise LineCountError unless lines.count == 53
    return lines
  end

  class ParsingError < StandardError ; end
  class LineCountError < ParsingError ; end
  class EmploymentStatusTotalsError < ParsingError ; end
  class EmployedNonemployedTotalsError < ParsingError ; end
end
