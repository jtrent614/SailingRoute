//
//  SavedRoutesTableViewController.swift
//  SailingRoute
//
//  Created by Jeff Trent on 8/20/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import UIKit
import MapKit

class SavedRoutesTableViewController: UITableViewController {
    
    var routes: [TraveledRoute]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        routes = UserDefaults.standard.getRoutes()
        tableView.reloadData()
        
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeCell", for: indexPath)
        if let route = routes?[indexPath.row] {
            
            let mainText = "\(route.placemark?.name! ?? "")"
            
            cell.textLabel?.text = "\(mainText == "" ? "" : (mainText + " - "))\(route.dateDescription)"
            cell.detailTextLabel?.text = "\(route.distanceDescription) nm - \(String(describing: route.averageSpeed)) avg kts - \(route.locations.count) data points"
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            routes?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        guard !editing, let routes = routes else { return }
    
        UserDefaults.standard.updateSavedRoutes(routes)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as? UITableViewCell
        
        var destination = segue.destination
        if let nc = destination as? UINavigationController {
            destination = nc.visibleViewController ?? destination
        }
        
        if segue.identifier == "showSavedRoute" {
            if let vc = destination as? MapSavedRouteViewController {
                let row = tableView.indexPath(for: cell!)?.row
                vc.route = routes?[row!]
            }
        }
    }
    
    
}
