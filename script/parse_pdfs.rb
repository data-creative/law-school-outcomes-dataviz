require "pry"

require_relative "../lib/employment_summary_report"

seeds = [
  {year: 2014, url: "https://www.wcl.american.edu/career/documents/statistics2014.pdf"},
  {year: 2014, url: "https://www.fordham.edu/download/downloads/id/1166/class_of_2014_at_10_months.pdf"},
  {year: 2014, url: "https://www.law.georgetown.edu/careers/ocs/upload/ABA-Website-Info.pdf"},
  {year: 2014, url: "https://www.law.gmu.edu/assets/files/career/ABAEmploymentSummary2014.pdf"},
  {year: 2014, url: "https://www.law.gwu.edu/sites/www.law.gwu.edu/files/downloads/Employement_Data_2014.pdf"},
  {year: 2014, url: "https://www.qu.edu/content/dam/qu/documents/sol/2014ABAEmploymentSummary.pdf"},
  {year: 2014, url: "http://www.uchastings.edu/career-office/docs/2014_ABA_Stats.pdf"},
  {year: 2014, url: "https://www.law.uconn.edu/sites/default/files/content-page/Graduate%20Employment%20Outcomes%20Class%20of%202014.pdf"},

  {year: 2015, url: "https://www.wcl.american.edu/career/documents/statistics2015_000.pdf"},
  {year: 2015, url: "https://www.fordham.edu/download/downloads/id/5271/class_of_2015_at_10_months.pdf"},
  {year: 2015, url: "https://www.law.georgetown.edu/careers/upload/Employment-Summary-for-2015-Graduates.pdf"},
  {year: 2015, url: "https://www.law.gmu.edu/assets/files/career/ABAEmploymentSummary2015.pdf"},
  {year: 2015, url: "https://www.law.gwu.edu/sites/www.law.gwu.edu/files/downloads/GW-Law-ABA-Employment-Data-for-Class-of-2015.pdf"},
  {year: 2015, url: "https://www.qu.edu/content/dam/qu/documents/sol/2015ABAEmploymentSummary.pdf"},
  {year: 2015, url: "http://www.uchastings.edu/career-office/docs/ABA%20Summary%20for%20website.pdf"},
  {year: 2015, url: "https://www.law.uconn.edu/sites/default/files/content-page/Graduate-Employment-Outcomes-Class-of-2015-2016-04-26.pdf"}

]

seeds.select{|seed| seed[:year] == 2015 }.each do |seed|

  puts "-----------------------"
  puts "-----------------------"
  pp seed

  report = EmploymentSummaryReport.new(url: seed[:url], year: seed[:year])

  pp report.year

  pp report.school_info

  pp report.total_grads

  pp report.employment_status_results

  pp report.employment_type_results

  pp report.employment_location_results
end
