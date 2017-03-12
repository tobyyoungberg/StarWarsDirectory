//
//  MasterViewController.swift
//  StarWarsDirectory
//
//  Created by Toby Youngberg on 3/8/17.
//  Copyright © 2017 Toby Youngberg. All rights reserved.
//

import UIKit
import RealmSwift

class DirectoryViewController: UITableViewController {

    var personViewController: PersonViewController? = nil
    
    var realm : Realm?
    var results : Results<Person>?
    var notificationToken : NotificationToken?


    override func viewDidLoad() {
        super.viewDidLoad()

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.personViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? PersonViewController
        }

        // Update the dataset if network is available
        WebPersonManager.shared.updatePeopleFromWeb { error in
            if error != nil {
                NSLog("Error retrieving data: %@", error?.localizedDescription ?? "Unknown Web Manager Error")
            }
            DispatchQueue.main.async {
                
                //Setup our realm datasource
                self.realm = try? Realm()
                self.results = try? Realm().objects(Person.self).sorted(byKeyPath: "birthdate")
                
                //Register for realm notifiations
                self.notificationToken = self.results?.addNotificationBlock { (changes: RealmCollectionChange) in
                    switch changes {
                    case .initial:
                        self.tableView.reloadData()
                    case .update(_, let deletions, let insertions, let modifications):
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .fade)
                        self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .fade)
                        self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .fade)
                        self.tableView.endUpdates()
                    case .error(let err):
                        NSLog("Error updating realm results: %@", err.localizedDescription)
                    }
                }
            }
        }
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName : defaultTitleFont], for: .normal)
        
        self.tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let person = results?[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! PersonViewController
                controller.person = person
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PersonCell

        let person = results?[indexPath.row]
        cell.person = person
        
        return cell
    }


}

class PersonCell : UITableViewCell {
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var personName: UILabel!

    
    var person : Person? {
        didSet {
            self.personName.text = person?.name
            self.profileImage.setProfileImage(person: person)
        }
    }
    
    //Clear the cell for reuse so we don't see incorrect data.
    override func prepareForReuse() {
        personName.text = ""
        profileImage.image = nil
    }
}

