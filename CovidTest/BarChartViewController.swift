//
//  BarChartViewController.swift
//  CovidTest
//
//  Created by shihab on 4/19/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import Foundation
import Charts

class BarChartViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var location: LocationInfo!
    var dateList: [String] = []
    var caseList: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barChartView.delegate = self
        descriptionLabel.text = "Loading data..."
        
        if LocationManager.shared.dictForPastCases[self.location.name] != nil {
            loadInitialData()
        }else{
            NotificationCenter.default.addObserver(self, selector: #selector(onDidReceivePastCases(_:)), name: .kDidLoadPastCasesInformation, object: nil)
            LocationManager.shared.getPastCasesForLocation(withLocation: self.location)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.dateList.removeAll()
        self.caseList.removeAll()
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
    
    func loadInitialData() {
        if LocationManager.shared.dictForPastCases[self.location.name] != nil {
            let val = LocationManager.shared.dictForPastCases[self.location.name]!
            print("loading data...-> \(val.count)")
            let ordered = val.sorted {
                guard let s1 = $0["date"], let s2 = $1["date"] else {
                    return false
                }
                return s1 < s2
            }
            self.dateList.removeAll()
            self.caseList.removeAll()
            for itemDict in ordered{
                let dateComponents = itemDict["date"]!.split(separator: "-")
                var shortDate: String
                if dateComponents.count > 1 {
                    shortDate = dateComponents[dateComponents.count-2] + "/" + dateComponents[dateComponents.count-1]
                }else{
                    shortDate = itemDict["date"]!
                }
                self.dateList.append(shortDate)
                self.caseList.append((itemDict["cases"]! as NSString).integerValue)
            }
            loadChart()
        }
    }
    
    func loadChart() {
        barChartView.noDataText = "You need to provide data for the chart."
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<self.dateList.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(self.caseList[i]))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Covid Patients")
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        chartData.setValueFormatter(DefaultValueFormatter(formatter:formatter))
        
        chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        //chartDataSet.colors = ChartColorTemplates.colorful()
        
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
        
        var percentageText: String = ""
        if self.caseList.count > 1{
            let prev = self.caseList[self.caseList.count-2]
            let increase: Double = Double((self.caseList.last! - prev)*100/prev)
            percentageText = "\n with increase = \(increase)%"
            print(percentageText)
        }
        descriptionLabel.text = location.name + "\n Current Patients = \(self.caseList.last!)" + percentageText
    }
    
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: Highlight) {
        print("selected")
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
