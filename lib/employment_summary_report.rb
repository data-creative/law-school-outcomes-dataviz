require "open-uri"
require "pdf-reader"
require "pry"

class EmploymentSummaryReport
  attr_reader :url, :lines

  def initialize(url)
    @url = url
    @lines = read_lines(url)
  end

  def year
    @year ||= lines[5].gsub("EMPLOYMENT SUMMARY FOR ","").gsub(" GRADUATES","").to_i
  end

  def school_lines
    lines.first(5)
  end

  def city_state_zip
    school_lines[3].strip.upcase
  end

  def state_zip
    city_state_zip.split(", ").last
  end

  def university
    {
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

  private

  def read_lines(url)
    io = open(url)
    reader = PDF::Reader.new(io)
    lines = reader.pages.first.text.split("\n")
    lines.select!{|line| line.size > 0 }
    lines.map!{|line| line.strip }
    raise LineCountError unless lines.count == 53
    return lines
  end

  class ReportParseError < StandardError ; end
  class LineCountError < ReportParseError ; end
end
