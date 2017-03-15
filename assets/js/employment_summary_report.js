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

  static findByShortName(reports, schoolShortName) {
    return reports.find(function(rpt){ return rpt.schoolShortName == schoolShortName })
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
