require "pry"

require_relative "../lib/employment_summary_report"

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

puts report.school_info

puts report.employment_status_results

puts report.employment_type_results

puts report.employment_location_results
