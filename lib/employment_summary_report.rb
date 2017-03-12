require "open-uri"
require "pdf-reader"
require "pry"

require_relative "employment_summary_report/section"
require_relative "employment_summary_report/sections/employment_location_section"
require_relative "employment_summary_report/sections/employment_status_section"
require_relative "employment_summary_report/sections/employment_type_section"

class EmploymentSummaryReport
  class LineCountError < StandardError ; end

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
    # todo
  end

  def employment_location_results
    @employment_location_results ||= EmploymentLocationSection.new(self).results
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
end
