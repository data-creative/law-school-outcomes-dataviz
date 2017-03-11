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
