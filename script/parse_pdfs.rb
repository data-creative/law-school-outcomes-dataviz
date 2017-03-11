require "open-uri"
require "pdf-reader"
require "pry"

pdf_url = 'https://www.fordham.edu/download/downloads/id/5271/class_of_2015_at_10_months.pdf' #todo: loop through all urls from employment_summaries.json
io = open(pdf_url)
reader = PDF::Reader.new(io)

binding.pry

# reader.pages.first.text.split("\n").each do |line| puts line end
