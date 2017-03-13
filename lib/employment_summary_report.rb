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
  alias school_name domain

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

  def results
    {
      url: url,
      school_name: school_name,
      school_info: school_info,
      year: year,
      total_grads: total_grads,
      #pct_employed_grads: pct_employed_grads,
      employment_outcomes:{
        #total_employed_grads: total_employed_grads,
        statuses: employment_status_results,
        types: employment_type_results,
        locations: employment_location_results
      }
    }
  end

  private

  def file_source
    File.join(File.expand_path("../../reports/#{year}/", __FILE__), "#{domain}.pdf")
  end

  def url_source
    open(url)
  end

  def download
    FileUtils.rm_rf(file_source)

    File.open(file_source, "wb") do |local_file|
      open(url, "rb") do |remote_file|
        local_file.write(remote_file.read)
      end
    end
  end

  def io
    if File.exist?(file_source)
      file_source
    else
      download # optionally download for next time, to avoid future network requests
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
