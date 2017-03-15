'use strict';

class EmploymentSummaryReport {
  constructor(data) {
    this.data = data
  }

  //
  // CLASS METHODS
  //

  static employmentStatuses(){
    return [
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
      "Employment Status Unknown"
    ]
  }

  static employedStatuses(){
    return this.employmentStatuses().filter(function(status){ return status.includes("Employed") })
  }

  static unemployedStatuses(){
    return this.employmentStatuses().filter(function(status){ return !status.includes("Employed") })
  }

  static employmentTypes(){
    return [
      {type: "Law Firms (Unknown Size)", defaultDisplayGroup: "Law Firm (Other)"},
      {type: "Law Firms (Solo)", defaultDisplayGroup: "Law Firm (Other)"},
      {type: "Law Firms (2 - 10)", defaultDisplayGroup: "Law Firm (Other)"},
      {type: "Law Firms (11 - 25)", defaultDisplayGroup: "Law Firm (Other)"},
      {type: "Law Firms (26 - 50)", defaultDisplayGroup: "Law Firm (Other)"},
      {type: "Law Firms (51 - 100)", defaultDisplayGroup: "Law Firm (Other)"},
      {type: "Law Firms (101 - 250)", defaultDisplayGroup: "Law Firm (Big)"},
      {type: "Law Firms (251 - 500)", defaultDisplayGroup: "Law Firm (Big)"},
      {type: "Law Firms (501 +)", defaultDisplayGroup: "Law Firm (Big)"},

      {type: "Business & Industry", defaultDisplayGroup: "Business & Industry"},
      {type: "Government", defaultDisplayGroup: "Government"},
      {type: "Pub. Int.", defaultDisplayGroup: "Public Interest"},
      {type: "Clerkships - Federal", defaultDisplayGroup: "Clerkship"},
      {type: "Clerkships - State & Local", defaultDisplayGroup: "Clerkship"},
      {type: "Clerkships - Other", defaultDisplayGroup: "Clerkship"},
      {type: "Education", defaultDisplayGroup: "Employed (Other)"},
      {type: "Employer Type Unknown", defaultDisplayGroup: "Employed (Other)"}
    ]
  }

  //
  // INSTANCE METHODS
  //

  get schoolShortName(){
    return this.data.school_name.toUpperCase()
  }

  get totalGrads(){
    return this.data.total_grads
  }

  // Returns an array of counts representing graduates belonging to any of the selectedStatuses.
  // @param [Array] selectedStatuses e.g. e.g. ["Pursuing Graduate Degree Full Time", "Unemployed - Start Date Deferred", "Unemployed - Not Seeking", "Unemployed - Seeking", "Employment Status Unknown"]
  statusCounts(selectedStatuses) {
    return this.data.employment_outcomes.statuses.filter(function(statusCount){
      return selectedStatuses.includes(statusCount.status)
    }).map(function(statusCount){
      return statusCount.count
    })
  }

  // Returns an array of counts representing graduates employed in any of the selectedTypes.
  // @param [Array] selectedTypes e.g. ["Law Firms (101 - 250)", "Law Firms (251 - 500)", "Law Firms (501 +)"]
  typeCounts(selectedTypes) {
    return this.data.employment_outcomes.types.filter(function(typeCount){
      return selectedTypes.includes(typeCount.type)
    }).map(function(typeCount){
      return typeCount.count
    })
  }

}
