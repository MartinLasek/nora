//
//  ViewController.swift
//  nora
//
//  Created by Martin Lasek on 06.10.18.
//  Copyright © 2018 Martin Lasek. All rights reserved.
//

import UIKit

class HashtagGroupVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Properties
    let cellIdentifier = "hashtagGroupCell"
    var hashtagGroupList = [HashtagGroup]()
    var selectedHashtagGroup: HashtagGroup!

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hashtagGroupList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HashtagGroupTableViewCell
        else {
            fatalError("No cell with identifier 'HashtagGroup' found")
        }

        cell.hashtagGroupLabel.text = hashtagGroupList[indexPath.row].name
        return cell
    }

    @IBAction func addHashtagGroupButton(_ sender: Any) {

        // Create an alert controller with a textfield
        let alert = UIAlertController(title: "Enter a unique Name", message: nil, preferredStyle: .alert)
        alert.addTextField()

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in return}))

        // Add "Create" action that grabs the value from the textfield and adds
        // a new HashtagGroup to the list with the textfield value as a name
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak alert] _ in

            guard
                let alert = alert,
                let textFields = alert.textFields,
                !textFields.isEmpty,
                let name = textFields[0].text,
                !name.isEmpty  // We don't allow empty strings like: ""
            else {
                print("Empty Name.")
                return
            }

            self.hashtagGroupList.append(HashtagGroup(name: name))

            guard
                let cell = self.tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) as? HashtagGroupTableViewCell
            else {
                fatalError("Could not downcast cell to HashtagCollectionTableViewCell")
            }

            cell.hashtagGroupLabel.text = name
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }))

        self.present(alert, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? HashtagGroupDetailVC {

            // get selected row
            if let indexPath = self.tableView.indexPathForSelectedRow {
                vc.hashtagGroup = hashtagGroupList[indexPath.row]
            }
        }
    }
}
