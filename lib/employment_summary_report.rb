require "open-uri"
require "pdf-reader"
require "pry"

require_relative "employment_summary_report/section"
require_relative "employment_summary_report/sections/employment_status_section"
require_relative "employment_summary_report/sections/employment_type_section"

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

  def employment_status_results
    @employment_status_results ||= EmploymentStatusSection.new(self).results
  end

  def employment_type_results
    @employment_type_results ||= EmploymentTypeSection.new(self).results
  end

  def school_funded_employment_results
    ["todo"]
  end

  #
  # EMPLOYMENT LOCATION
  #

  LOCATION_TYPES = [
    "State - Largest Employment",
    "State - 2nd Largest Employment",
    "State - 3rd Largest Employment",
    "Employed in Foreign Countries"
  ]

  def employment_location_section
    Section.new({
      :report => self,
      :header_content => "EMPLOYMENT LOCATION",
      :number_of_lines => LOCATION_TYPES.count + 1 # includes header line
    }) # header line is followed by a line for each of the three most popular states, followed by a line to indicate employment in foreign countries
  end

  def state_types
    LOCATION_TYPES.select{|location_type| location_type.include?("STATE - ")}
  end

  def foreign_type
    LOCATION_TYPES.find{|location_type| location_type == "Employed in Foreign Countries" }
  end

  def employment_location_results
    counts = []

    state_types.each do |state_type|
      line = employment_location_section.lines.find{|line| line.include?(state_type) }
      state_and_count = line.gsub(state_type,"").strip.split("    ").select{|str| !str.empty?}.map{|str| str.strip }
      counts << {type: state_type, location: state_and_count.first, count: state_and_count.last}
    end

    foreign_line = employment_location_section.lines.find{|line| line.include?(foreign_type) }
    foreign_count = last_number(foreign_line)
    counts << {type: foreign_type, location: foreign_type, count: foreign_count}

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
end
