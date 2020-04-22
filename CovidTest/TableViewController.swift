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

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        segmentedControl.setTitle("District", forSegmentAt: 0)
        segmentedControl.setTitle("Dhaka City", forSegmentAt: 1)
        
        if LocationManager.shared.dictForCityLocation.count == 0 {
            NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveData(_:)), name: .kDidLoadLocationInformation, object: nil)
        }
        if LocationManager.shared.dictForCityLocation.count == 0 {
            NotificationCenter.default.addObserver(self, selector: #selector(onDidReceiveDataForCity(_:)), name: .kDidLoadLocationInformationForCity, object: nil)
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

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        var location: LocationInfo
        switch segmentedControl.selectedSegmentIndex
        {
            case 0:
                location = self.locations[indexPath.row]
            case 1:
                location = self.locationsForCity[indexPath.row]
            default:
                return UITableViewCell()
        }
        cell.textLabel?.text = location.name
        cell.detailTextLabel?.text = "Current cases: \(location.cases)"
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

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
    
    private func loadInitialData() {
        if LocationManager.shared.dictForDistrictLocation.count > 0 {
            for (key, location) in LocationManager.shared.dictForDistrictLocation{
                self.locations.append(location)
            }
            self.locations = self.locations.sorted(by: { $0.cases > $1.cases })
            self.tableView.reloadData()
        }
    }
    
    private func loadInitialDataForCity(){
        if LocationManager.shared.dictForCityLocation.count > 0 {
            for (key, location) in LocationManager.shared.dictForCityLocation{
                self.locationsForCity.append(location)
            }
            self.locationsForCity = self.locationsForCity.sorted(by: { $0.cases > $1.cases })
            self.tableView.reloadData()
        }
    }

    @IBAction func segmentedControlPressed(_ sender: Any) {
        switch segmentedControl?.selectedSegmentIndex
        {
            case 0:
                print("Segment 0")
            case 1:
                print("Segment 1")
            default:
                break
        }
        self.tableView.reloadData()
    }
}
