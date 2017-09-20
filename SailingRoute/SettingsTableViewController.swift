
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
    
    func addMark(_ sender: UIBarButtonItem) {
        print("add mark button hit!")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "AddMarkTableViewController") as! AddMarkTableViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func raceModeToggle(_ sender: UISwitch) {
        Settings.shared.raceMode = !Settings.shared.raceMode
    }
    
    @IBAction func showAllBuoysToggle(_ sender: UISwitch) {
        Settings.shared.showAllBuoys = !Settings.shared.showAllBuoys
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return settingsCellNames.count
        case 1:
            return buoyList.buoys.filter { $0.usedInRace == true }.count
        case 2:
            return buoyList.buoys.filter { $0.usedInRace == false }.count
        default:
            return 0
        }
    }
    

    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let buoy = getBuoyAt(indexPath: fromIndexPath)
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
    
    private func setBuoyRaceOrder() {
        buoyList.raceOrder = [Buoy]()
        
        let count = tableView.numberOfRows(inSection: 1)
        for x in 0..<count {
            let indexPath = IndexPath(row: x, section: 1)
            let cell = tableView.cellForRow(at: indexPath)
            let identifier = cell?.textLabel?.text
            let buoy = buoyList.buoyWithIdentifier(id: identifier!)
            buoyList.raceOrder.append(buoy)
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
    
    func getBuoyAt(indexPath: IndexPath) -> Buoy {
        return indexPath.section == 1 ? buoyList.used[indexPath.row] : buoyList.unused[indexPath.row]
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
        toggleAddMarkButton(editing: editing)
        if !editing {
            setBuoyRaceOrder()
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
    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        let buoy = getBuoyAt(indexPath: indexPath)
//        if indexPath.section == 1 {  // used
//            let newIndexPath = IndexPath(row: tableView.numberOfRows(inSection: 2), section: 2)
//            tableView(tableView, moveRowAt: indexPath, to: newIndexPath)
//            buoyList.used.remove(at: <#T##Int#>)
//        } else if indexPath.section == 2 {   // unused
//            
//        }
//    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 ? false : true
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath.section == 0 ? sourceIndexPath : proposedDestinationIndexPath
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return indexPath.section == 0 ? .none : .delete
        return .none
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaders[section]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0 ? false : true
    }
    
    let settingsCellNames: [Int:String] = [
        0: "raceModeCell",
        1: "showAllBuoysCell",
        2: "viewDistanceCell",
    ]
    
    let sectionHeaders: [Int:String] = [
        0: "Settings",
        1: "Marks used in race",
        2: "Unused marks"
    ]
}
