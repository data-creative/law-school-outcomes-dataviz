require "open-uri"
require "pdf-reader"
require "pry"

require_relative "employment_summary_report/school"
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

  def school_info
    @school_info || School.new(self).info
  end

  def employment_status_section
    EmploymentStatusSection.new(self)
  end

  def employment_status_results
    @employment_status_results ||= employment_status_section.results
  end

  def total_grads
    employment_status_section.total_graduates
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
    report_name = "gwu.pdf" # report_names.sample
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
end
