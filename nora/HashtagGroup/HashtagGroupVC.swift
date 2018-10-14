//
//  ViewController.swift
//  nora
//
//  Created by Martin Lasek on 06.10.18.
//  Copyright © 2018 Martin Lasek. All rights reserved.
//

import UIKit

class HashtagGroupVC: UIViewController {

    // MARK: Properties
    let cellIdentifier = "hashtagGroupCell"
    var hashtagGroupList = [HashtagGroup]()
    var selectedHashtagGroup: HashtagGroup!

    @IBOutlet weak var tableView: UITableView!

    // load hashtag group before table cell hook is executed
    // so it contains all hashtags
    override func viewWillAppear(_ animated: Bool) {
       loadHashtagGroups()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    // `+` button action to add a new group
    @IBAction func addHashtagGroupButton(_ sender: Any) {

        // Create an alert controller with a textfield
        let alert = UIAlertController(title: "Enter a unique Name", message: nil, preferredStyle: .alert)
        alert.addTextField()

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // [weak alert] means you want to use a local variable called `alert` inside
        // of the closure with a weak reference so it is released after execution
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

            // Alert and early return
            // if name for group already exists
            if self.hashtagGroupList.contains(where: { $0.name == name }) {
                // Create an alert controller with a textfield
                let uniqueAlert = UIAlertController(title: "Name must be unique!", message: nil, preferredStyle: .alert)
                uniqueAlert.addAction(UIAlertAction(title: "Ok", style: .default))
                self.present(uniqueAlert, animated: true, completion: nil)
                return
            }

            hashtagRepository.insert(HashtagGroup(name: name))
            self.hashtagGroupList = hashtagRepository.selectAllHashtagGroups()

            guard
                let cell = self.tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) as? HashtagGroupTableViewCell
            else {
                fatalError("Could not downcast cell to HashtagCollectionTableViewCell")
            }

            cell.hashtagGroupLabel.text = name
            self.tableView.reloadData()
        }))

        self.present(alert, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? HashtagGroupDetailVC {

            // get indexPath for selected row
            if let indexPath = self.tableView.indexPathForSelectedRow {
                vc.hashtagGroup = hashtagGroupList[indexPath.row]
            }
        }
    }

    func loadHashtagGroups() {
        hashtagGroupList = hashtagRepository.selectAllHashtagGroups()
        self.tableView.reloadData()
    }
}

// MARK: TableView

extension HashtagGroupVC: UITableViewDelegate, UITableViewDataSource {
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

        let hashtagGroup = hashtagGroupList[indexPath.row]
        cell.hashtagGroup = hashtagGroup
        cell.hashtagGroupLabel.text = hashtagGroup.name
        cell.onCopyHashtagCompletion = {
            // the alert view
            let alert = UIAlertController(title: "copied to clipboard", message: nil, preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)

            // Dismiss alert after 1 second
            let when = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: when) {
                alert.dismiss(animated: true, completion: nil)
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let hashtagGroup = hashtagGroupList[indexPath.row]
            guard let id = hashtagGroup.id else {
                return
            }

            hashtagRepository.removeHashtagGroupBy(hashtagGroupId: id)
            hashtagGroupList = hashtagRepository.selectAllHashtagGroups()

            // it must come after deleting from database
            // becuase hashtagGroupList must at this point have the same number
            // of entries like the rows after the deletion happened
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

/*
override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
        objects.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    } else if editingStyle == .insert {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}
*/
