require "open-uri"
require "pdf-reader"
require "domainatrix"
require "pry"

require_relative "employment_summary_report/school"
require_relative "employment_summary_report/section"
require_relative "employment_summary_report/sections/employment_location_section"
require_relative "employment_summary_report/sections/employment_status_section"
require_relative "employment_summary_report/sections/employment_type_section"

class EmploymentSummaryReport
  class LineCountError < StandardError ; end

  attr_reader :url, :year, :lines

  def initialize(url:, year:)
    @url = url
    @year = year
    @lines = read_lines
  end

  def domain
    Domainatrix.parse(url).domain
  end

  ###def year
  ###  @year ||= lines[5].gsub("EMPLOYMENT SUMMARY FOR ","").gsub(" GRADUATES","").to_i
  ###end

  def school_info
    @school_info || School.new(self).info
  end

  def employment_status_section
    @employment_status_section ||= EmploymentStatusSection.new(self)
  end

  def employment_status_results
    employment_status_section.results
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

  def file_source
    File.join(File.expand_path("../reports/#{year}/", __FILE__), "#{domain}.pdf")
  end

  def url_source
    open(url)
  end

  def io
    if File.exist?(file_source)
      file_source
    else
      #TODO: download_for_next_time
      url_source
    end
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
