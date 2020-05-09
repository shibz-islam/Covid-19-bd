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
    var record: Record?
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
        segmentedControl.setTitle(Constants.ViewControllerConstants.segmentedControlFirstIndex, forSegmentAt: 0)
        segmentedControl.setTitle(Constants.ViewControllerConstants.segmentedControlSecondIndex, forSegmentAt: 1)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Data...")
        tableView.refreshControl = refreshControl
        
        let nibCell = UINib(nibName: "CustomTableViewCell", bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: "CustomCell")
        let nibSection = UINib(nibName: "CustomSectionHeaderView", bundle: nil)
        tableView.register(nibSection, forHeaderFooterViewReuseIdentifier: "CustomSectionHeader")
        let nibDetailSection = UINib(nibName: "CustomDetailSectionHeaderView", bundle: nil)
        tableView.register(nibDetailSection, forHeaderFooterViewReuseIdentifier: "CustomDetailSectionHeader")
        
        if LocationManager.shared.dictForDistrictLocation.count == 0 {
            NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .kDidLoadLocationInformation, object: nil)
        }
        if LocationManager.shared.dictForCityLocation.count == 0 {
            NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveDataForCity(_:)), name: .kDidLoadLocationInformationForCity, object: nil)
        }
        if LocationManager.shared.dictForRecentRecords[Constants.LocationConstants.defaultCountryName] == nil {
            NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveSummaryData(_:)), name: .kDidLoadSummaryInformation, object: nil)
        }
        
        loadInitialData()
        loadInitialDataForCity()
        loadSummaryData()
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomTableViewCell
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
        cell.locationNameLabel?.text = location.name
        cell.countLabel?.text = "Cases: \(location.cases)"
        
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
        switch segmentedControl.selectedSegmentIndex
        {
            case 0:
                if self.record != nil{
                    return 100
                }
            case 1:
                break
            default:
                break
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Dequeue with the reuse identifier
        switch segmentedControl.selectedSegmentIndex
        {
            case 0:
                if let rec = self.record{
                    let detailedHeader = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomDetailSectionHeader") as! CustomDetailSectionHeaderView
                    detailedHeader.nameLabel.text = rec.name
                    detailedHeader.dateLabel.text = rec.date
                    detailedHeader.casesLabel.text = String(rec.cases)
                    detailedHeader.curedLabel.text = String(rec.recoveries)
                    detailedHeader.deathLabel.text = String(rec.fatalities)
                    let tapGestureRecognizer = UITapGestureRecognizer(
                        target: self,
                        action: #selector(headerTapped(_:))
                    )
                    detailedHeader.addGestureRecognizer(tapGestureRecognizer)
                    return detailedHeader
                }else{
                    let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomSectionHeader") as! CustomSectionHeaderView
                    header.titleLabel.text = "Cases in Bangladesh"
                    header.casesLabel.text = String(totalCasesCountryLevel)
                    return header
                }
            case 1:
                let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomSectionHeader") as! CustomSectionHeaderView
                header.titleLabel.text = "Cases in Dhaka"
                header.casesLabel.text = String(totalCases)
                return header
            default:
                break
        }
        return UITableViewHeaderFooterView()
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
    
    @objc func headerTapped(_ sender: UITapGestureRecognizer?) {
        print("Section header tapped!")
        let location = LocationInfo(name: Constants.LocationConstants.defaultCountryName, parent: "", level: Constants.KeyStrings.keyCountry, latitude: 0.0, longitude: 0.0, cases: 0, date: "")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let barVC = storyboard.instantiateViewController(withIdentifier: "barChartVC") as! BarChartViewController
        barVC.location = location
        self.present(barVC, animated: true, completion: nil)
    }
    
    private func loadInitialData() {
        if LocationManager.shared.dictForDistrictLocation.count > 0 {
            //print("***dictForDistrictLocation \(LocationManager.shared.dictForDistrictLocation.count)")
            self.locations.removeAll()
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
            self.locationsForCity.removeAll()
            for (key, location) in LocationManager.shared.dictForCityLocation{
                self.locationsForCity.append(location)
                totalCases = totalCases + location.cases
            }
            self.locationsForCity = self.locationsForCity.sorted(by: { $0.cases > $1.cases })
            self.tableView.reloadData()
        }
        if let mainDistrictLocation = LocationManager.shared.dictForDistrictLocation[Constants.LocationConstants.defaultDistrictName]{
            totalCases = mainDistrictLocation.cases
        }
    }
    
    private func loadSummaryData(){
        if let rec = LocationManager.shared.dictForRecentRecords[Constants.LocationConstants.defaultCountryName] {
            self.record = rec
            if let cases = record?.cases{
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
    
    @objc func refreshData(_ sender: Any){
        print("Refresh Data...")
        if LocationManager.shared.dictForDistrictLocation.count == 0 {
            LocationManager.shared.getLocationData(withIsLevelCity: false, withDate: Date()) { (success, message) in
                DispatchQueue.main.async {
                    if success == true {
                        self.loadInitialData()
                    }
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
        }
        else if LocationManager.shared.dictForCityLocation.count == 0 {
            LocationManager.shared.getLocationData(withIsLevelCity: true, withDate: Date()) { (success, message) in
                DispatchQueue.main.async {
                    if success == true {
                        self.loadInitialDataForCity()
                    }
                    self.tableView.refreshControl?.endRefreshing()
                }
            }
        }
        else if LocationManager.shared.dictForRecentRecords[Constants.LocationConstants.defaultCountryName] == nil {
            LocationManager.shared.getRecentSummary(withName:Constants.LocationConstants.defaultCountryName, withType: Constants.KeyStrings.keyCountry) { (success, message) in
                DispatchQueue.main.async {
                    if success == true {
                        self.loadInitialDataForCity()
                    }
                    self.loadSummaryData()
                }
            }
        }
        else{
            self.tableView.refreshControl?.endRefreshing()
        }
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
