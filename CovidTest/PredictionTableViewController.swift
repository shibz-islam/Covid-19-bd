//
//  PredictionTableViewController.swift
//  CovidTest
//
//  Created by shihab on 5/11/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import UIKit
import SideMenu

class PredictionTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var predTableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var records = [PredictionRecord]()
    var filteredRecords = [PredictionRecord]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        predTableView.delegate = self
        predTableView.dataSource = self
        
        self.navigationItem.title = Constants.appName
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search locations..."
        predTableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        predTableView.keyboardDismissMode = .onDrag
        
        let nibCell = UINib(nibName: "PredictionTableViewCell", bundle: nil)
        predTableView.register(nibCell, forCellReuseIdentifier: "predictionCell")
        let nibSection = UINib(nibName: "PredictionSectionHeaderView", bundle: nil)
        predTableView.register(nibSection, forHeaderFooterViewReuseIdentifier: "PredictionSectionHeader")
        
        setupSideMenuFromStoryboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFiltering {
            return self.filteredRecords.count
        }else{
            return self.records.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "predictionCell", for: indexPath) as! PredictionTableViewCell
        
        var record: PredictionRecord
        if self.isFiltering {
            record = self.filteredRecords[indexPath.row]
        }else{
            record = self.records[indexPath.row]
        }
        cell.locationNameLabel.text = record.name
        cell.caseLabel.text = String(record.cases)
        cell.predLabel.text = String(record.predCases)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        predTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.predTableView.dequeueReusableHeaderFooterView(withIdentifier: "PredictionSectionHeader") as! PredictionSectionHeaderView
        return header
    }

     // MARK: - Helper
    func loadData() {
        if LocationManager.shared.dictForDistrictLevelPredictionRecords.count > 0{
            self.records.removeAll()
            for (key, record) in LocationManager.shared.dictForDistrictLevelPredictionRecords{
                self.records.append(record)
            }
            self.records = self.records.sorted(by: { $0.cases > $1.cases })
            self.predTableView.reloadData()
        }
        else{
            LocationManager.shared.getPredictionData(withIsLevelCity: false, withIsNextDay: true)
            NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .kDidLoadPredictionDataNotification, object: nil)
        }
    }
    
    @objc private func onDidReceiveData(_ notification: Notification) {
        print("onDidReceiveData from TableView")
        DispatchQueue.main.async {
            NotificationCenter.default.removeObserver(self, name: .kDidLoadPredictionDataNotification, object: nil)
            self.loadData()
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


extension PredictionTableViewController: UISearchResultsUpdating, SideMenuNavigationControllerDelegate {
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        //print(searchBar.text)
        filteredRecords = self.records.filter {
            $0.name.lowercased().contains(searchBar.text!.lowercased())
        }
        predTableView.reloadData()
    }
    
    // MARK: - SideMenu
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
