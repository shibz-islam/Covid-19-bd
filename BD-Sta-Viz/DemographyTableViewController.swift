//
//  DemographyTableViewController.swift
//  BD-Sta-Viz
//
//  Created by shihab on 5/19/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import UIKit
import SideMenu

class DemographyTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var locations = [DemographyInfo]()
    var totalCasesCountryLevel: Int = 0
    var filteredLocations = [DemographyInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = Constants.appName
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search locations..."
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Data...")
        tableView.refreshControl = refreshControl
        
        let nibCell = UINib(nibName: "CustomTableViewCell", bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: "CustomCell")
        let nibSection = UINib(nibName: "CustomSectionHeaderView", bundle: nil)
        tableView.register(nibSection, forHeaderFooterViewReuseIdentifier: "CustomSectionHeader")
        
        if LocationManager.shared.dictForDemographicInfo.count == 0 {
            NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .kDidLoadDemographyDataNotification, object: nil)
        }
        loadInitialData()
        setupSideMenuFromStoryboard()
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFiltering {
            return self.filteredLocations.count
        }else{
            return self.locations.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomTableViewCell
        var location: DemographyInfo
        if isFiltering {
            location = self.filteredLocations[indexPath.row]
        }else{
            location = self.locations[indexPath.row]
        }
        cell.locationNameLabel?.text = location.name
        cell.countLabel?.text = formatNumber(withNumber: location.population)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var tappedLocation: DemographyInfo?
        if isFiltering {
            tappedLocation = self.filteredLocations[indexPath.row]
        }else{
            tappedLocation = self.locations[indexPath.row]
        }
        print("Tapped: \(tappedLocation?.name)")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let barVC = storyboard.instantiateViewController(withIdentifier: "barChartVC") as! BarChartViewController
        if let location = tappedLocation{
            barVC.demoLocation = location
            barVC.isDemographicData = true
            self.present(barVC, animated: true, completion: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Dequeue with the reuse identifier
        let header = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomSectionHeader") as! CustomSectionHeaderView
        header.titleLabel.text = "Bangladesh"
        header.casesLabel.text = formatNumber(withNumber: totalCasesCountryLevel)
        header.headerTitleLabel.text = "Region"
        header.headerSubTitleLabel.text = "Population"
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(headerTapped(_:))
        )
        header.addGestureRecognizer(tapGestureRecognizer)
        return header
    }
    
    // MARK: - Helper
    @objc private func onDidReceiveData(_ notification: Notification) {
        print("onDidReceiveData...Table")
        DispatchQueue.main.async {
            NotificationCenter.default.removeObserver(self, name: .kDidLoadDemographyDataNotification, object: nil)
            self.loadInitialData()
        }
    }
    
    @objc func headerTapped(_ sender: UITapGestureRecognizer?) {
        print("Section header tapped!")
        let location = DemographyInfo(name: Constants.LocationConstants.defaultCountryName,
                       parent: "",
                       level: Constants.KeyStrings.keyCountry,
                       population: 0,
                       area: 0,
                       year: "",
                       areaUnit: "")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let barVC = storyboard.instantiateViewController(withIdentifier: "barChartVC") as! BarChartViewController
        barVC.demoLocation = location
        barVC.isDemographicData = true
        self.present(barVC, animated: true, completion: nil)
    }
    
    private func loadInitialData() {
        if LocationManager.shared.dictForDemographicInfo.count > 0 {
            self.locations.removeAll()
            self.totalCasesCountryLevel = 0
            self.locations = LocationManager.shared.getDemographicData()
            for location in self.locations{
                self.totalCasesCountryLevel = self.totalCasesCountryLevel + location.population
            }
            self.locations = self.locations.sorted(by: { $0.population > $1.population })
            self.tableView.reloadData()
        }
    }
    
    @objc func refreshData(_ sender: Any){
        print("Refresing...")
        loadInitialData()
        self.tableView.refreshControl?.endRefreshing()
    }
    
    func formatNumber(withNumber num:Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: num))!
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
extension DemographyTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        //print(searchBar.text)
        filteredLocations = self.locations.filter {
            $0.name.lowercased().contains(searchBar.text!.lowercased())
        }
        tableView.reloadData()
    }
}

// MARK: - SideMenuNavigationControllerDelegate
extension DemographyTableViewController: SideMenuNavigationControllerDelegate {
    private func setupSideMenuFromStoryboard() {
        // Define the menus
        SideMenuManager.default.rightMenuNavigationController = storyboard?.instantiateViewController(withIdentifier: Constants.StoryboardConstants.sideMenuNavigationControllerID) as? SideMenuNavigationController
        
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
        //SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: view)
    }
    
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Appearing! (animated: \(animated))")
    }
    
    func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Appeared! (animated: \(animated))")
    }
    
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappearing! (animated: \(animated))")
    }
    
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
        print("SideMenu Disappeared! (animated: \(animated))")
    }
}
