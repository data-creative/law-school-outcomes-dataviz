# Data Observations

## Assumptions

  + Data available in PDF format, organized according to a common structure.
    + Data on first page of PDF only. Second page contains data dictionary.
    + Data includes five sections: University identification, EMPLOYMENT STATUS, EMPLOYMENT TYPE, LAW SCHOOL/UNIVERSITY FUNDED POSITIONS, EMPLOYMENT LOCATION.
    + Section order may differ from year-to-year.
    + After parsing the PDF and removing empty lines, there are 53 lines (rows).

## Decisions

  + Don't care about full-time vs part-time columns. Only care about row totals (last column).
  + Given different section order from year-to-year, focus on 2015 structure first.
  + Don't group or classify employment types or law firm sizes. Let the client make those decisions.
