//
//  SideMenuTableViewController.swift
//  BD-Sta-Viz
//
//  Created by shihab on 5/10/20.
//  Copyright © 2020 shihab. All rights reserved.
//

import UIKit
import SafariServices

class SideMenuTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var menuTableView: UITableView!
    let menu = ["Home", "About the App", "About Us"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        menuTableView.delegate = self
        menuTableView.dataSource = self
        
        menuTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        menuTableView.backgroundColor = UIColor.lightGray
        
        let nibSection = UINib(nibName: "SideMenuHeaderView", bundle: nil)
        menuTableView.register(nibSection, forHeaderFooterViewReuseIdentifier: "SideMenuSectionHeader")
        menuTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        menuTableView.backgroundColor = UIColor.themeSlateGray
        menuTableView.separatorStyle = .none
        
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menu.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = menu[indexPath.row]
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.themeLightSlateGray
        var image: UIImage?
        let symbolConf = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium, scale: .medium)
        switch indexPath.row {
            case 0:
                image = UIImage(systemName: "house", withConfiguration: symbolConf)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            case 1:
                image = UIImage(systemName: "info.circle", withConfiguration: symbolConf)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            case 2:
                image = UIImage(systemName: "doc.plaintext", withConfiguration: symbolConf)?.withTintColor(.white, renderingMode: .alwaysOriginal)
            default: break
        }
        if let img = image {
            cell.imageView?.image = img
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //print("didSelectRowAt")
        //performSegue(withIdentifier: "detailSeg", sender: self)
        switch indexPath.row {
            case 0:
                //Home
                self.dismiss(animated: true, completion: nil)
            case 1:
                //Helpful sites
                let svc = SFSafariViewController(url: Constants.AppUrls.aboutApp)
                self.present(svc, animated: true, completion: nil)
            case 2:
                //About us
                let svc = SFSafariViewController(url: Constants.AppUrls.aboutUs)
                self.present(svc, animated: true, completion: nil)
            default: break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let detailedHeader = self.menuTableView.dequeueReusableHeaderFooterView(withIdentifier: "SideMenuSectionHeader") as! SideMenuHeaderView
        return detailedHeader
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

}
