//
//  StepsTableViewController.swift
//  KLPlatform
//
//  Created by KL on 1/4/2018.
//  Copyright © 2018 KL. All rights reserved.
//

import UIKit
import MapKit

class StepsTableViewController: UITableViewController {
    
    var routeSteps = [MKRouteStep]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows
        return routeSteps.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("StepsTableViewCell", owner: self, options: nil)?.first as! StepsTableViewCell
        
        // Configure the cell...
        cell.textLabel?.text = routeSteps[indexPath.row].instructions
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
