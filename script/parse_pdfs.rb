require "pry"

require_relative "../lib/employment_summary_report"

class EmployedGraduatesTotalsError < StandardError ; end

# @param [String] line e.g. "New York               34"
def last_number(line)
  line.split(" ").last.to_i
end

urls = [
  #"https://www.law.georgetown.edu/careers/ocs/upload/ABA-Website-Info.pdf",
  "https://www.law.georgetown.edu/careers/upload/Employment-Summary-for-2015-Graduates.pdf",
  #"https://www.law.gwu.edu/sites/www.law.gwu.edu/files/downloads/Employement_Data_2014.pdf",
  "https://www.law.gwu.edu/sites/www.law.gwu.edu/files/downloads/GW-Law-ABA-Employment-Data-for-Class-of-2015.pdf",
  #"https://www.wcl.american.edu/career/documents/statistics2014.pdf",
  "https://www.wcl.american.edu/career/documents/statistics2015_000.pdf",
  #"https://www.fordham.edu/download/downloads/id/1166/class_of_2014_at_10_months.pdf",
  "https://www.fordham.edu/download/downloads/id/5271/class_of_2015_at_10_months.pdf",
  #"http://www.uchastings.edu/career-office/docs/2014_ABA_Stats.pdf",
  "http://www.uchastings.edu/career-office/docs/ABA%20Summary%20for%20website.pdf",
  #"https://www.law.uconn.edu/sites/default/files/content-page/Graduate%20Employment%20Outcomes%20Class%20of%202014.pdf",
  "https://www.law.uconn.edu/sites/default/files/content-page/Graduate-Employment-Outcomes-Class-of-2015-2016-04-26.pdf",
  #"https://www.qu.edu/content/dam/qu/documents/sol/2015ABAEmploymentSummary.pdf",
  "https://www.qu.edu/content/dam/qu/documents/sol/2014ABAEmploymentSummary.pdf",
  #"https://www.law.gmu.edu/assets/files/career/ABAEmploymentSummary2014.pdf",
  "https://www.law.gmu.edu/assets/files/career/ABAEmploymentSummary2015.pdf"
]

url = urls.sample
report = EmploymentSummaryReport.new(url)

lines = report.lines

pp report.school

pp report.employment_status

#
# SECTION C - EMPLOYMENT TYPE
#

employment_types = [
  {label:"Law Firms",
    sizes:["Solo", "2 - 10", "11 - 25", "26 - 50", "51 - 100", "101 - 250", "251 - 500", "501 +", "Unknown Size"]},
  {label:"Business & Industry"},
  {label:"Government"},
  {label:"Pub. Int."},
  {label:"Clerkships - Federal"},
  {label:"Clerkships - State & Local"},
  {label:"Clerkships - Other"},
  {label:"Education"},
  {label:"Employer Type Unknown"}
]
law_firms_type = employment_types.find{|h| h[:label] == "Law Firms"}
law_firm_sizes = law_firms_type[:sizes]

type_section = { # header line is followed by a line per employment type, including a line per law firm size, followed by a line for "Total Graduates"
  first_line_index: lines.each_with_index.find{|line, i| line.include?("EMPLOYMENT TYPE")}.last,
  number_of_lines: employment_types.count + law_firm_sizes.count + 1 + 1 # includes header line and totals line
}
type_section[:last_line_index] = type_section[:first_line_index] + type_section[:number_of_lines]
type_lines = lines[type_section[:first_line_index] .. type_section[:last_line_index]]

type_counts = []

law_firm_sizes.each do |size|
  line = type_lines.find{|line| line.include?(size) }
  number = last_number(line)
  type_counts << {type: "Law Firms (#{size})", count: number}
end

counted_types = employment_types.reject{|h| h[:label] == "Law Firms"}.map{|h| h[:label]}
counted_types.each do |type|
  line = type_lines.find{|line| line.include?(type) }
  number = last_number(line)
  type_counts << {type: type, count: number}
end

pp type_counts

total_employed_graduates = last_number(type_lines.last)
calculated_total_employed_graduates = type_counts.map{|h| h[:count] }.reduce{|sum, x| sum + x}
raise EmployedGraduatesTotalsError if total_employed_graduates != calculated_total_employed_graduates

#
# SECTION D - LAW SCHOOL/UNIVERSITY FUNDED POSITIONS
#

# SECTION E - EMPLOYMENT LOCATION

location_types = [
  "State - Largest Employment",
  "State - 2nd Largest Employment",
  "State - 3rd Largest Employment"
]

locations_section = { # header line is followed by a line for each of the three most popular states, followed by a line to indicate employment in foreign countries
  first_line_index: lines.each_with_index.find{|line, i| line.include?("EMPLOYMENT LOCATION")}.last,
  number_of_lines: location_types.count + 1 + 1 # includes header line and foreign locations type
}
locations_section[:last_line_index] = locations_section[:first_line_index] + locations_section[:number_of_lines]
location_lines = lines[locations_section[:first_line_index] .. locations_section[:last_line_index]]

locations = location_types.map do |location_type|
  line = location_lines.find{|line| line.include?(location_type) }
  location_number = line.gsub(location_type,"").strip.split("    ").select{|str| !str.empty?}.map{|str| str.strip }
  location = location_number.first
  number = location_number.last
  {type: location_type, location: location, count: number}
end

foreign_location_type = "Employed in Foreign Countries"
foreign_line = location_lines.find{|line| line.include?(foreign_location_type) }
foreign_count = last_number(foreign_line)
locations << {type: foreign_location_type, location: foreign_location_type, count: foreign_count}

pp locations
