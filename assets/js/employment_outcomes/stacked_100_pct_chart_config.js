'use strict';

// NOTE: this class requires the "report.js" file. So either load it in the document before loading this script (not a best practice), or require the "Report" class formally by using some kind of server-side asset compilation tool (require.js, browserify, webpack, etc.)

//
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
  // @param [Array] groupings contains objects like: {group: 'Big Law', color: "#000", types: ["Law Firm (100-500)", "Law Firm (500+)"] }
  constructor(year, reports, groupings) {
    this.year = year
    this.reports = reports
    this.groupings = groupings
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

  // @return [Array] An array of objects like: {name: 'Big Law', color: "#000", data: [{name:'School A', y:3}, {name:'School B', y:4}, {name:'School C', y:4}, {name:'School D', y:2}, {name:'School E', y:5} ] }
  series(unemploymentStatuses) {
    var series = [{
      name: 'Unemployed',
      color: colorbrewer.Reds[9][6],
      data: this.statusesData(unemploymentStatuses)
    }]
    const chartConfig = this
    this.groupings.forEach(function(grouping){
      series = series.concat({
        name: grouping.group,
        color: grouping.color,
        data: chartConfig.typesData(grouping.types)
      })
    })
    return series
  }

  totalGrads(schoolShortName){
    return Report.findByShortName(this.reports, schoolShortName).totalGrads
  }

  tooltipFormat(column){
    var tooltip = ''
    var headerFormat = `<b>${column.x.toUpperCase()}</b><br/>`
    headerFormat += `<b>Total Grads: ${this.totalGrads(column.x)}</b><br/>`
    tooltip += headerFormat
    column.points.forEach(function(pt){
      var pointFormat = `<span style="color:${pt.series.color}">${pt.series.name}</span>: <b>${pt.y}</b> (${  Highcharts.numberFormat(pt.percentage, 0)  }%)<br/>`
      tooltip += pointFormat
    })
    return tooltip
  }

  options(){
    const chartConfig = this
    return {
      chart: {
        type: 'column',
        marginBottom:50 // make room to display the subtitle below the chart.
      },
      exporting:{
        enabled:false,
        buttons: {contextButton: {text: 'Export'}}
      },
      credits: {enabled: false},
      legend:{
        align:'right',
        layout:'vertical',
        verticalAlign:'middle'
      },
      title: {text: 'Employment Outcomes by Law School'},
      subtitle: {
        text: 'Copyright 2017 Data Creative (http://data-creative.info). Does not distinguish between short-term/long-term or full-time/part-time employment. Law firm size considered "Big" if greater than or equal to 100 employees.',
        align:'left',
        verticalAlign:'bottom',
        floating:true,
        y: -5,
        style: { "font-size":10, "font-style":"italic" }
      },
      xAxis: {
        categories: chartConfig.categories,
        type: "category",
        opposite:true,
        labels:{
          //formatter:function(){
          //  return `<b>${this.value}</b>`
          //},
          style: { "color": "#000", "cursor": "default", "fontSize": "11px" }
        }
      },
      yAxis: {
        min: 0,
        title: {
          text: `PERCENTAGE OF ${chartConfig.year} GRADUATES`,
          style: { "color": "#000", "cursor": "default", "fontSize": "11px" }
        },
        stackLabels: {enabled: true},
        labels:{
          enabled:true,
          format: '{value}%',
          style: { "color": "#000", "cursor": "default", "fontSize": "11px" }
        }
      },
      tooltip: {
        //headerFormat: '<b>{point.x}</b><br/>', // '<b>{point.key}</b><br/>'
        //pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.y}</b> ({point.percentage:.0f}%)<br/>',
        formatter: function(){ return chartConfig.tooltipFormat(this) }, // passes the column object
        shared: true,
        borderColor: '#000',
        followPointer:true,
        backgroundColor:'rgba(255,255,255, 1)' // use white background and remove opacity
      },
      plotOptions: {
        column: {
          stacking: 'percent',
          dataLabels: {
            enabled: true,
            format: '{point.percentage:.0f}%', // '{point.y} ({point.percentage:.0f}%)',
            color: (Highcharts.theme && Highcharts.theme.dataLabelsColor) || 'white'
          },
          events: {legendItemClick: function () { return false; } } // disable data-filtering functionality when series in legend is clicked
        }
      },
      series: chartConfig.series(Report.unemployedStatuses())
    }
  }

}
