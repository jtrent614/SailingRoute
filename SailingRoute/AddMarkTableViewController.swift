//
//  AddMarkTableViewController.swift
//  SailingRoute
//
//  Created by Jeff Trent on 9/19/17.
//  Copyright © 2017 jtrent. All rights reserved.
//

import UIKit
import CoreLocation

class AddMarkTableViewController: UITableViewController {
        
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var latTextField: UITextField!
    @IBOutlet weak var longTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Add Mark"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(addMarkAndReturn))
    }

    func addMarkAndReturn() {
        if validateTextFields() {
            let tabBarController = self.tabBarController as! SailingRouteTabBarController
            let buoyList = tabBarController.buoyList
            
            let coordinate = CLLocationCoordinate2D(latitude: latTextField.text!.double!, longitude: latTextField.text!.double!)
            let newBuoy = Buoy(identifier: nameTextField.text!, coordinate: coordinate, usedInRace: false, buoyList: buoyList)
            buoyList.addBuoy(newBuoy)
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func validateTextFields() -> Bool {
        guard let name = nameTextField.text, let lat = latTextField.text?.double, let long = longTextField.text?.double,
            !name.isEmpty,
            abs(lat) <= 90,
            abs(long) <= 180
        else {
            return false
        }
        return true
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

}

extension String {
    var double: Double? {
        return Double(self)
    }
}
