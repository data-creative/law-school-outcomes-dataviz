# Law School Outcomes - Data Visualization

Uses the [Law School Outcomes](https://github.com/data-creative/law-school-outcomes-ruby) ruby library to process Employment Summary Reports from ABA-accredited law schools, and writes the results to JSON.

Provides a decision-making dashboard for comparing employment outcomes across various schools of interest.

## Usage

Visit in a browser at https://data-creative.github.io/law-school-outcomes-dataviz/.

## Contributing

### Installation

```` sh
git clone git@github.com:data-creative/law-school-outcomes-dataviz.git
cd law-school-outcomes-dataviz/
````

### Collect Report URLs

Add new Employment Summary Report URL(s) to `script/parse_pdfs.rb`.

### Convert PDF files to JSON

```` sh
ruby script/parse_pdfs.rb
````

### Run Local Web Server

```` sh
python -m SimpleHTTPServer 8888
````
