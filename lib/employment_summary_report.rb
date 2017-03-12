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
    section = {
      first_line_index: lines.each_with_index.find{|line, i| line.include?("EMPLOYMENT STATUS")}.last,
      number_of_lines: EMPLOYMENT_STATUSES.count + 1 + 1 # includes header line and totals line
    } # header line is followed by a line per employment status, followed by a line for "Total Graduates"
    section[:last_line_index] = section[:first_line_index] + section[:number_of_lines]

    return lines[section[:first_line_index] .. section[:last_line_index]]
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





















  #
  # EMPLOYMENT TYPE
  #

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

  def law_firm_sizes
    EMPLOYMENT_TYPES.find{|h| h[:label] == "Law Firms"}[:sizes]
  end

  def employment_type_lines
    section = {
      first_line_index: lines.each_with_index.find{|line, i| line.include?("EMPLOYMENT TYPE")}.last,
      number_of_lines: EMPLOYMENT_TYPES.count + law_firm_sizes.count + 1 + 1 # includes header line and totals line
    } # header line is followed by a line per employment type, including a line per law firm size, followed by a line for "Total Graduates"
    section[:last_line_index] = section[:first_line_index] + section[:number_of_lines]
    return lines[section[:first_line_index] .. section[:last_line_index]]
  end

  def employment_type
    counts = []

    law_firm_sizes.each do |size|
      line = employment_type_lines.find{|line| line.include?(size) }
      number = last_number(line)
      counts << {type: "Law Firms (#{size})", count: number}
    end

    employment_types = EMPLOYMENT_TYPES.reject{|h| h[:label] == "Law Firms"}.map{|h| h[:label]}
    employment_types.each do |type|
      line = employment_type_lines.find{|line| line.include?(type) }
      number = last_number(line)
      counts << {type: type, count: number}
    end

    total_employed_graduates = last_number(employment_type_lines.last)
    calculated_total_employed_graduates = counts.map{|h| h[:count] }.reduce{|sum, x| sum + x}
    raise EmployedGraduatesTotalsError if total_employed_graduates != calculated_total_employed_graduates

    return counts
  end

























  private

  def io
    #io = open(url)

    # test using local file for now:
    dir = File.expand_path("../../reports/2015/", __FILE__)
    report_names = Dir.entries(dir).reject{|file_name| [".","..",".gitkeep"].include?(file_name) }
    report_name = report_names.sample
    @school_domain = report_name
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

  # @param [String] line e.g. "New York               34"
  def last_number(line)
    line.split(" ").last.to_i
  end

  class ParsingError < StandardError ; end
  class LineCountError < ParsingError ; end
  class EmploymentStatusTotalsError < ParsingError ; end
  class EmployedNonemployedTotalsError < ParsingError ; end
  class EmployedGraduatesTotalsError < ParsingError ; end
end
