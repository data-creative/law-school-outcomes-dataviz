'use strict';

// PROCESSES REPORT DATA INTO CHART DATA
//
//
//var chartSeries = [
//    {
//      name: 'Unemployed',
//      data: [
//        {name:'School A', y:5},
//        {name:'School B', y:3},
//        {name:'School C', y:4},
//        {name:'School D', y:7},
//        {name:'School E', y:2},
//      ]
//    },
//    {
//      name: 'Public Interest',
//      data: [
//        {name:'School A', y:2},
//        {name:'School B', y:2},
//        {name:'School C', y:3},
//        {name:'School D', y:2},
//        {name:'School E', y:1},
//      ]
//    },
//    {
//      name: 'Big Law',
//      data: [
//        {name:'School A', y:3},
//        {name:'School B', y:4},
//        {name:'School C', y:4},
//        {name:'School D', y:2},
//        {name:'School E', y:5},
//      ]
//    }
//]
//
//
// ... OR ...
//
//
// var chartCategories = ['School A', 'School B', 'School C', 'School D', 'School E']
//
// var chartSeries = [
//   {
//     name: 'Unemployed',
//     data: [5, 3, 4, 7, 2] // must be in same order as ['School A', 'School B', 'School C', 'School D', 'School E']
//   },
//   {
//     name: 'Public Interest',
//     data: [2, 2, 3, 2, 1] // must be in same order as ['School A', 'School B', 'School C', 'School D', 'School E']
//   },
//   {
//     name: 'Big Law',
//     data: [3, 4, 4, 2, 5] // must be in same order as ['School A', 'School B', 'School C', 'School D', 'School E']
//   }
// ]

class Stacked100PctChartConfig {
  constructor(reports) {
    this.reports = reports
  }

  //
  // CLASS METHODS
  //

  //
  // INSTANCE METHODS
  //

  // @return ['School A', 'School B', 'School C', 'School D', 'School E']
  get categories(){
    return this.reports.map(function(report){ return report.schoolShortName })
  }

  // @param [Object] employmentStatuses e.g. ["Employed - JD Required", "Employed - JD Advantage"] }
  // @return [5, 3, 4, 7, 2] (must be in same order as categories)
  statusesData(employmentStatuses){
    return this.reports.map(function(report){
      return report.sumOfStatusCounts(employmentStatuses)
    })
  }

  // @param [Object] employmentTypes e.g. ["Education", "Employer Type Unknown"] }
  // @return [5, 3, 4, 7, 2] (must be in same order as categories)
  typesData(employmentTypes){
    return this.reports.map(function(report){
      return report.sumOfTypeCounts(employmentTypes)
    })
  }

  // @param [Array] employmentTypeGroupings e.g. An array of objects like: {group: 'Big Law', color: "#000", types: ["Law Firm (100-500)", "Law Firm (500+)"] }
  // @return [Array] An array of objects like: {name: 'Big Law', color: "#000", data: [{name:'School A', y:3}, {name:'School B', y:4}, {name:'School C', y:4}, {name:'School D', y:2}, {name:'School E', y:5} ] }
  series(unemploymentStatuses, employmentTypeGroupings) {
    var series = [{
      name: 'Unemployed',
      color: colorbrewer.Reds[9][6],
      data: this.statusesData(unemploymentStatuses)
    }]

    const component = this
    employmentTypeGroupings.forEach(function(grouping){
      series = series.concat({
        name: grouping.group,
        color: grouping.color,
        data: component.typesData(grouping.types)
      })
    })

    return series
  }






}
