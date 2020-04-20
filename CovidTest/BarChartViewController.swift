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
    var months: [String]!
    var descriptionText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barChartView.delegate = self
        
        //Dummy data
        months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let unitsSold = [546, 4.0, 200, 3.0, 12.0, 47, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
        
        setChart(dataPoints: months, values: unitsSold)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        months.removeAll()
        super.viewDidDisappear(animated)
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
            barChartView.noDataText = "You need to provide data for the chart."
            
            var dataEntries: [BarChartDataEntry] = []
            
            for i in 0..<dataPoints.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
                dataEntries.append(dataEntry)
            }
            
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Covid Patients")
            let chartData = BarChartData(dataSet: chartDataSet)
            barChartView.data = chartData
            
            chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
            //chartDataSet.colors = ChartColorTemplates.colorful()
            
            barChartView.xAxis.labelPosition = .bottom
            barChartView.xAxis.granularity = 1
            barChartView.xAxis.granularityEnabled = true
            barChartView.xAxis.labelCount = dataPoints.count // number of points on X axis
            if barChartView.xAxis.labelPosition == .bottom {
                barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
            }
            barChartView.leftAxis.granularityEnabled = true
            barChartView.leftAxis.granularity = 1.0
            barChartView.rightAxis.enabled = false
            
            //barChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
            
            //barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
            barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInBounce)
            
//            let ll = ChartLimitLine(limit: 10.0, label: "Target")
//            barChartView.rightAxis.addLimitLine(ll)
            
            descriptionLabel.text = descriptionText
            
        }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: Highlight) {
        print("selected")
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
