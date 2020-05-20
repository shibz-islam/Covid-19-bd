//
//  BarChartViewController.swift
//  BD-Sta-Viz
//
//  Created by shihab on 4/19/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import Foundation
import Charts

class BarChartViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var location: LocationInfo?
    var dateList: [String] = []
    var caseList: [Int] = []
    var curedList: [Int] = []
    var deathList: [Int] = []
    let maxRecords: Int = 10
    
    var isDemographicData: Bool = false
    var demoLocation: DemographyInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barChartView.delegate = self
        descriptionLabel.text = "No data for the chart right now. Please try again later..."
        
        if isDemographicData == false {
            if let loc = self.location {
                if loc.name == Constants.LocationConstants.defaultCountryName {
                    if LocationManager.shared.dictForAllRecords[loc.name] != nil {
                        loadInitialDataForSummary()
                    }else{
                        LocationManager.shared.getSummaryPastCasesForLocation(withLocation: loc)
                        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveSummaryPastCases(_:)), name: .kDidLoadSummaryPastCasesInformationNotification, object: nil)
                    }
                }else{
                    if LocationManager.shared.dictForAllRecords[loc.name] != nil {
                        loadInitialData()
                    }else{
                        LocationManager.shared.getPastCasesForLocation(withLocation: loc)
                        NotificationCenter.default.addObserver(self, selector: #selector(onDidReceivePastCases(_:)), name: .kDidLoadPastCasesInformation, object: nil)
                    }
                }
            }
        }
        else{
            loadInitialDataForPopulation()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.dateList.removeAll()
        self.caseList.removeAll()
        self.curedList.removeAll()
        self.deathList.removeAll()
        NotificationCenter.default.removeObserver(self)
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Helper
    
    @objc private func onDidReceivePastCases(_ notification: Notification) {
        print("onDidReceivePastCases...")
        DispatchQueue.main.async {
            self.loadInitialData()
        }
    }
    
    @objc private func onDidReceiveSummaryPastCases(_ notification: Notification) {
        print("onDidReceiveSummaryPastCases...")
        DispatchQueue.main.async {
            self.loadInitialDataForSummary()
        }
    }
    
    func loadInitialData() {
        if let loc = self.location {
            if LocationManager.shared.dictForAllRecords[loc.name] != nil {
                var ordered = LocationManager.shared.dictForAllRecords[loc.name]!
                if ordered.count > maxRecords {
                    let arraySlice = ordered.suffix(maxRecords)
                    ordered = Array(arraySlice)
                }
                self.dateList.removeAll()
                self.caseList.removeAll()
                for record in ordered{
                    let dateComponents = record.date.split(separator: "-")
                    var shortDate: String
                    if dateComponents.count > 1 {
                        shortDate = dateComponents[dateComponents.count-2] + "/" + dateComponents[dateComponents.count-1]
                    }else{
                        shortDate = record.date
                    }
                    self.dateList.append(shortDate)
                    self.caseList.append(record.cases)
                }
                loadChart()
            }
        }
    }
    
    func loadInitialDataForSummary() {
        if let loc = self.location {
            if LocationManager.shared.dictForAllRecords[loc.name] != nil {
                var ordered = LocationManager.shared.dictForAllRecords[loc.name]!
                if ordered.count > 7 {
                    let arraySlice = ordered.suffix(7)
                    ordered = Array(arraySlice)
                }
                for record in ordered{
                    let dateComponents = record.date.split(separator: "-")
                    var shortDate: String
                    if dateComponents.count > 1 {
                        shortDate = dateComponents[dateComponents.count-2] + "/" + dateComponents[dateComponents.count-1]
                    }else{
                        shortDate = record.date
                    }
                    self.dateList.append(shortDate)
                    self.caseList.append(record.cases)
                    self.curedList.append(record.recoveries)
                    self.deathList.append(record.fatalities)
                }
                loadSummaryChart()
            }
        }
    }
    
    func loadInitialDataForPopulation() {
        if let locationList = LocationManager.shared.dictForDemographicInfo[demoLocation!.name] {
            let orderedList = locationList.sorted(by: {$0.date < $1.date })
            var populationList = [Int]()
            for location in orderedList {
                self.dateList.append(location.date)
                populationList.append(location.population)
            }
            loadChartForPopulation(withPopulationList: populationList)
        }
        else{
            print("Data not available...!")
        }
    }
    
    func loadChart() {
        barChartView.noDataText = "No data for the chart right now. Please try again later"
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<self.dateList.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(self.caseList[i]))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Patients")
        chartDataSet.colors = [UIColor.themeDarkOrange]
        
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        chartData.setValueFormatter(DefaultValueFormatter(formatter:formatter))
        
        setChartParameters()
        
        var percentageText: String = ""
        if self.caseList.count > 1{
            let prev = self.caseList[self.caseList.count-2]
            let increase: Double = Double((self.caseList.last! - prev)*100/prev)
            if increase >= 0 {
                percentageText = "\n with increase = \(increase)%"
            }
            else{
                percentageText = "\n with decrease = \(abs(increase))%"
            }
            //print(percentageText)
        }
        if let loc = self.location {
            descriptionLabel.text = loc.name + "\n Current Patients = \(self.caseList.last!)" + percentageText
        }
    }
    
    func loadSummaryChart() {
        barChartView.noDataText = "No data for the chart right now. Please try again later..."
        var dataEntries: [BarChartDataEntry] = []
        var dataEntriesCured: [BarChartDataEntry] = []
        var dataEntriesDeaths: [BarChartDataEntry] = []
        
        for i in 0..<self.dateList.count {
            dataEntries.append(BarChartDataEntry(x: Double(i), y: Double(self.caseList[i])))
            dataEntriesCured.append(BarChartDataEntry(x: Double(i), y: Double(self.curedList[i])))
            dataEntriesDeaths.append(BarChartDataEntry(x: Double(i), y: Double(self.deathList[i])))
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Patients")
        let chartDataSetCured = BarChartDataSet(entries: dataEntriesCured, label: "Cured")
        let chartDataSetDeaths = BarChartDataSet(entries: dataEntriesDeaths, label: "Fatalities")
        chartDataSet.colors = [UIColor.themeDarkOrange]
        chartDataSetCured.colors = [UIColor.themePaleGreen]
        chartDataSetDeaths.colors = [UIColor.themeDarkRed]
        
        let chartData = BarChartData(dataSets: [chartDataSet, chartDataSetCured, chartDataSetDeaths])
        
        let groupSpace = 0.16
        let barSpace = 0.08
        let barWidth = 0.20
         //(0.25 + 0.05) * 3 + 0.25 = 1.00 -> interval per "group"
        let groupCount = self.dateList.count
        let startDate = 0
        chartData.barWidth = barWidth
        chartData.groupBars(fromX: Double(startDate), groupSpace: groupSpace, barSpace: barSpace)
        barChartView.xAxis.axisMinimum = Double(startDate)
        barChartView.xAxis.axisMaximum = Double(startDate) + chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace) * Double(groupCount)
        barChartView.xAxis.centerAxisLabelsEnabled = true
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        chartData.setValueFormatter(DefaultValueFormatter(formatter:formatter))
        
        barChartView.data = chartData
        
        setChartParameters()
        
        var percentageText: String = ""
        if self.caseList.count > 1{
            let prev = self.caseList[self.caseList.count-2]
            var increase: Double = Double((Double(self.caseList.last!) - Double(prev))*100/Double(prev))
            if increase >= 0 {
                percentageText = "\n with increase = "
            }
            else{
                percentageText = "\n with decrease = "
                increase = abs(increase)
            }
            let roundedFormat = String(format: "%.2f", increase)
            percentageText = percentageText + "\(roundedFormat)%"
        }
        if let loc = self.location {
            descriptionLabel.text = loc.name + "\n Current Patients = \(self.caseList.last!)" + percentageText
        }
    }
    
    func loadChartForPopulation(withPopulationList populationList:[Int]) {
        barChartView.noDataText = "No data for the chart right now. Please try again later"
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<self.dateList.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(populationList[i]))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Population")
        chartDataSet.colors = [UIColor.themeDarkOrange]
        
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 0
        chartData.setValueFormatter(DefaultValueFormatter(formatter:formatter))
        
        setChartParameters()
        barChartView.leftAxis.valueFormatter = MyLeftAxisFormatter()
        
        var percentageText: String = ""
        if populationList.count > 1{
            let prev = populationList[populationList.count-2]
            var increase: Double = Double((Double(populationList.last!) - Double(prev))*100/Double(prev))
            if increase >= 0 {
                percentageText = "increase = "
            }
            else{
                percentageText = "decrease = "
                increase = abs(increase)
            }
            let roundedFormat = String(format: "%.2f", increase)
            percentageText = percentageText + "\(roundedFormat)%"
        }
        if let loc = self.demoLocation {
            descriptionLabel.text = loc.name + "\n Population " + percentageText
        }
    }
    
    func setChartParameters(){
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.granularity = 1
        barChartView.xAxis.granularityEnabled = false
        barChartView.xAxis.drawAxisLineEnabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.labelCount = self.dateList.count // number of points on X axis
        if barChartView.xAxis.labelPosition == .bottom {
            barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: self.dateList)
        }
        barChartView.leftAxis.granularityEnabled = false
        barChartView.leftAxis.granularity = 1.0
        barChartView.rightAxis.enabled = false
        
        //barChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInBounce)
        //let ll = ChartLimitLine(limit: 10.0, label: "Target")
        //barChartView.rightAxis.addLimitLine(ll)
    }
    
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: Highlight) {
        print("selected")
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

final class MyLeftAxisFormatter: NSObject, IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value))!
    }
}
