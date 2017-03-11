require "open-uri"
require "pdf-reader"
require "pry"

class LineCountError < StandardError ; end

def last_number(line)
  line.split(" ").last.to_i
end

#urls = [
#  #"https://www.law.georgetown.edu/careers/ocs/upload/ABA-Website-Info.pdf",
#  "https://www.law.georgetown.edu/careers/upload/Employment-Summary-for-2015-Graduates.pdf",
#  #"https://www.law.gwu.edu/sites/www.law.gwu.edu/files/downloads/Employement_Data_2014.pdf",
#  "https://www.law.gwu.edu/sites/www.law.gwu.edu/files/downloads/GW-Law-ABA-Employment-Data-for-Class-of-2015.pdf",
#  #"https://www.wcl.american.edu/career/documents/statistics2014.pdf",
#  "https://www.wcl.american.edu/career/documents/statistics2015_000.pdf",
#  #"https://www.fordham.edu/download/downloads/id/1166/class_of_2014_at_10_months.pdf",
#  "https://www.fordham.edu/download/downloads/id/5271/class_of_2015_at_10_months.pdf",
#  #"http://www.uchastings.edu/career-office/docs/2014_ABA_Stats.pdf",
#  "http://www.uchastings.edu/career-office/docs/ABA%20Summary%20for%20website.pdf",
#  #"https://www.law.uconn.edu/sites/default/files/content-page/Graduate%20Employment%20Outcomes%20Class%20of%202014.pdf",
#  "https://www.law.uconn.edu/sites/default/files/content-page/Graduate-Employment-Outcomes-Class-of-2015-2016-04-26.pdf",
#  #"https://www.qu.edu/content/dam/qu/documents/sol/2015ABAEmploymentSummary.pdf",
#  "https://www.qu.edu/content/dam/qu/documents/sol/2014ABAEmploymentSummary.pdf"
#]

urls = ["https://www.fordham.edu/download/downloads/id/5271/class_of_2015_at_10_months.pdf"]

urls.each do |url|
  io = open(url)
  reader = PDF::Reader.new(io)
  lines = reader.pages.first.text.split("\n")
  lines.select!{|line| line.size > 0 }
  lines.map!{|line| line.strip }
  raise LineCountError unless lines.count == 53

  year = lines[5].gsub("EMPLOYMENT SUMMARY FOR ","").gsub(" GRADUATES","").to_i

  #
  # SECTION A - UNIVERSITY IDENTIFICATION
  #

  school_lines = lines.first(5)
  city_state_zip = school_lines[3].strip.upcase
  state_zip = city_state_zip.split(", ").last

  university = {
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

  pp university

  #
  # SECTION B - EMPLOYMENT STATUS
  #

  employment_statuses = [
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

  status_section = {
    first_line_index: lines.each_with_index.find{|line, i| line.include?("EMPLOYMENT STATUS")}.last,
    number_of_lines: employment_statuses.count + 1 + 1 # includes header line and totals line
  } # header line is followed by a line per employment status, followed by a line for "Total Graduates"
  status_section[:last_line_index] = status_section[:first_line_index] + status_section[:number_of_lines]
  status_lines = lines[status_section[:first_line_index] .. status_section[:last_line_index]]

  status_counts = employment_statuses.map do |status|
    line = status_lines.find{|line| line.include?(status) }
    number = last_number(line)
    {status: status, count: number}
  end

  calculated_total = status_counts.map{|h| h[:count] }.reduce{|sum, x| sum + x}
  given_total = last_number(status_lines.last)
  raise EmploymentStatusTotalsError unless calculated_total == given_total

  pp status_counts

  # SECTION C - EMPLOYMENT TYPE

  binding.pry

  # SECTION D - LAW SCHOOL/UNIVERSITY FUNDED POSITIONS
  # SECTION E - EMPLOYMENT LOCATION

end
