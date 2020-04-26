//
//  TableViewController.swift
//  CovidTest
//
//  Created by shihab on 4/21/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var locations = [LocationInfo]()
    var locationsForCity = [LocationInfo]()
    var filteredLocations = [LocationInfo]()
    var summaryInfo: SummaryInfo?
    var totalCasesCountryLevel: Int = 0
    var totalCases: Int = 0
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        print("**** viewDidLoad")

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search locations..."
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true

        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        segmentedControl.setTitle("District", forSegmentAt: 0)
        segmentedControl.setTitle("Dhaka City", forSegmentAt: 1)
        
        let nib = UINib(nibName: "CustomSectionHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "CustomSectionHeader")
        
        if LocationManager.shared.dictForCityLocation.count == 0 {
            NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .kDidLoadLocationInformation, object: nil)
        }
        if LocationManager.shared.dictForCityLocation.count == 0 {
            NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveDataForCity(_:)), name: .kDidLoadLocationInformationForCity, object: nil)
        }
        if LocationManager.shared.dictSummary[ApplicationManager.shared.kCountryNameKey] == nil {
            LocationManager.shared.getSummary(withIsLevelCity: false)
            NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveSummaryData(_:)), name: .kDidLoadSummaryInformation, object: nil)
        }
        
        loadInitialData()
        loadInitialDataForCity()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFiltering {
            return self.filteredLocations.count
        }else{
            switch segmentedControl.selectedSegmentIndex
            {
                case 0:
                    return self.locations.count > 0 ? self.locations.count : 0
                case 1:
                    return self.locationsForCity.count > 0 ? self.locationsForCity.count : 0
                default:
                    return 0
            }
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        var location: LocationInfo
        if isFiltering {
            location = self.filteredLocations[indexPath.row]
        }else{
            switch segmentedControl.selectedSegmentIndex
            {
                case 0:
                    location = self.locations[indexPath.row]
                case 1:
                    location = self.locationsForCity[indexPath.row]
                default:
                    return UITableViewCell()
            }
        }
        cell.textLabel?.text = location.name
        cell.detailTextLabel?.text = "Current cases: \(location.cases)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var tappedLocation: LocationInfo?
        if isFiltering {
            tappedLocation = self.filteredLocations[indexPath.row]
        }else{
            switch segmentedControl.selectedSegmentIndex
            {
                case 0:
                    tappedLocation = self.locations[indexPath.row]
                case 1:
                    tappedLocation = self.locationsForCity[indexPath.row]
                default:
                    print("Unknown cell")
            }
        }
        //print("Tapped: \(tappedLocation?.name)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let barVC = storyboard.instantiateViewController(withIdentifier: "barChartVC") as! BarChartViewController
        if let location = tappedLocation{
            barVC.location = location
            self.present(barVC, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Dequeue with the reuse identifier
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomSectionHeader") as! CustomSectionHeaderView
        switch segmentedControl.selectedSegmentIndex
        {
            case 0:
                header.titleLabel.text = "Cases in Bangladesh"
                header.casesLabel.text = String(totalCasesCountryLevel)
            case 1:
                header.titleLabel.text = "Cases in Dhaka"
                header.casesLabel.text = String(totalCases)
            default:
                header.titleLabel.text = ""
                header.casesLabel.text = ""
                break
        }
        header.backgroundView?.backgroundColor = UIColor.brown
        return header
    }
    
    /*
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch segmentedControl.selectedSegmentIndex
    }*/

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Helper
    
    @objc private func onDidReceiveData(_ notification: Notification) {
        print("onDidReceiveData from TableView")
        DispatchQueue.main.async {
            NotificationCenter.default.removeObserver(self, name: .kDidLoadLocationInformation, object: nil)
            self.loadInitialData()
        }
    }
    
    @objc private func onDidReceiveDataForCity(_ notification: Notification) {
        print("onDidReceiveDataForCity from TableView")
        DispatchQueue.main.async {
            NotificationCenter.default.removeObserver(self, name: .kDidLoadLocationInformationForCity, object: nil)
            self.loadInitialDataForCity()
        }
    }
    
    @objc private func onDidReceiveSummaryData(_ notification: Notification) {
        print("onDidReceiveSummaryData from TableView")
        DispatchQueue.main.async {
            NotificationCenter.default.removeObserver(self, name: .kDidLoadSummaryInformation, object: nil)
            self.loadSummaryData()
        }
    }
    
    private func loadInitialData() {
        if LocationManager.shared.dictForDistrictLocation.count > 0 {
            //print("***dictForDistrictLocation \(LocationManager.shared.dictForDistrictLocation.count)")
            for (key, location) in LocationManager.shared.dictForDistrictLocation{
                self.locations.append(location)
                totalCasesCountryLevel = totalCasesCountryLevel + location.cases
            }
            self.locations = self.locations.sorted(by: { $0.cases > $1.cases })
            self.tableView.reloadData()
        }
    }
    
    private func loadInitialDataForCity(){
        if LocationManager.shared.dictForCityLocation.count > 0 {
            //print("***dictForCityLocation \(LocationManager.shared.dictForCityLocation.count)")
            for (key, location) in LocationManager.shared.dictForCityLocation{
                self.locationsForCity.append(location)
                totalCases = totalCases + location.cases
            }
            self.locationsForCity = self.locationsForCity.sorted(by: { $0.cases > $1.cases })
            self.tableView.reloadData()
        }
        if let mainDistrictLocation = LocationManager.shared.dictForDistrictLocation[ApplicationManager.shared.kMainDistrictNameKey]{
            totalCases = mainDistrictLocation.cases
        }
    }
    
    private func loadSummaryData(){
        if let summary = LocationManager.shared.dictSummary[ApplicationManager.shared.kCountryNameKey] {
            summaryInfo = summary
            if let cases = summaryInfo?.cases{
                totalCasesCountryLevel = cases
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func segmentedControlPressed(_ sender: Any) {
        switch segmentedControl?.selectedSegmentIndex
        {
            case 0:
                searchController.isActive = false
                print("Segment 0")
            case 1:
                searchController.isActive = false
                print("Segment 1")
            default:
                break
        }
        self.tableView.reloadData()
    }
    
    var isSearchBarEmpty: Bool {
        return self.searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }
}

// MARK: - UISearchResultsUpdating
extension TableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        //print(searchBar.text)
        switch segmentedControl.selectedSegmentIndex
        {
            case 0:
                filteredLocations = self.locations.filter {
                    $0.name.lowercased().contains(searchBar.text!.lowercased())
            }
            case 1:
                filteredLocations = self.locationsForCity.filter {
                    $0.name.lowercased().contains(searchBar.text!.lowercased())
            }
            default:
                print("Unknown segment")
        }
        tableView.reloadData()
    }
}
