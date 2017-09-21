
//
//  SettingsTableViewController.swift
//  SailingRoute
//
//  Created by Jeff Trent on 8/23/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    var buoyList: BuoyList = BuoyList()
    
    @IBAction func viewDistanceSlider(_ sender: UISlider) {
        let value = sender.value.rounded()
        Settings.shared.mapViewDistance = Double(value)
    }
    
    @IBAction func raceModeToggle(_ sender: UISwitch) {
        Settings.shared.raceMode = !Settings.shared.raceMode
    }
    
    @IBAction func showAllBuoysToggle(_ sender: UISwitch) {
        Settings.shared.showAllBuoys = !Settings.shared.showAllBuoys
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem?.title = "Edit Marks"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(SettingsTableViewController.addMark(_:)))
        self.navigationItem.title = "Settings"
        
        
        let tabBarController = self.tabBarController as! SailingRouteTabBarController
        buoyList = tabBarController.buoyList
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @objc func addMark(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AddMarkTableViewController") as! AddMarkTableViewController
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func getBuoyAt(indexPath: IndexPath) -> Buoy {
        return indexPath.section == 1 ? buoyList.used[indexPath.row] : buoyList.unused[indexPath.row]
    }
 
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        var buoy = getBuoyAt(indexPath: fromIndexPath)
        buoy.usedInRace = to.section == 1 ? true : false
        
        if fromIndexPath.section == 1 && to.section == 2 {
            buoyList.used.remove(at: fromIndexPath.row)
            buoyList.unused.insert(buoy, at: to.row)
        } else if fromIndexPath.section == 2 && to.section == 1 {
            buoyList.unused.remove(at: fromIndexPath.row)
            buoyList.used.insert(buoy, at: to.row)
        } else if fromIndexPath.section == 2 && to.section == 2 {
            buoyList.unused.remove(at: fromIndexPath.row)
            buoyList.unused.insert(buoy, at: to.row)
        } else if fromIndexPath.section == 1 && to.section == 1 {
            buoyList.used.remove(at: fromIndexPath.row)
            buoyList.used.insert(buoy, at: to.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: settingsCellNames[indexPath.row]!, for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "buoyCell", for: indexPath)
            cell.textLabel?.text = getBuoyAt(indexPath: indexPath).identifier
        }
        return cell
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
        toggleAddMarkButton(editing: editing)
        if !editing {
            UserDefaults.standard.saveBuoyList(buoyList)
        }
    }
    
    func toggleAddMarkButton(editing: Bool) {
        if editing {
            self.navigationItem.leftBarButtonItem?.title = "Add Mark"
            self.navigationItem.leftBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.leftBarButtonItem?.title = ""
            self.navigationItem.leftBarButtonItem?.isEnabled = false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            buoyList.unused.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 ? false : true
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath.section == 0 ? sourceIndexPath : proposedDestinationIndexPath
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return indexPath.section == 2 ? .delete : .none
//        return .none
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaders[section]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 ? false : true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionHeaders.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return settingsCellNames.count
        case 1:
            return buoyList.used.count
        case 2:
            return buoyList.unused.count
        default:
            return 0
        }
    }
    
    
    let settingsCellNames: [Int:String] = [
        0: "raceModeCell",
        1: "showAllBuoysCell",
        2: "viewDistanceCell",
    ]
    
    let sectionHeaders: [Int:String] = [
        0: "Settings",
        1: "Marks used",
        2: "Unused marks"
    ]
}
