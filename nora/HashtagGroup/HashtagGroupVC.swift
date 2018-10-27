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
            if self.hashtagGroupList.contains(where: {
                self.normalizeString($0.name) == self.normalizeString(name)
            }) {
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
                fatalError("Could not downcast cell to HashtagGroupTableViewCell")
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

    private func normalizeString(_ text: String) -> String {
        var result = text
        result = result.trimmingCharacters(in: .whitespaces)
        result = result.lowercased()
        return result
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

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteTitle = "Delete"
        let deleteAction = UIContextualAction(style: .destructive, title: deleteTitle, handler: { (action, view, completionHandler) in
            let hashtagGroup = self.hashtagGroupList[indexPath.row]
            guard let id = hashtagGroup.id else {
                return
            }
            hashtagRepository.removeHashtagGroupBy(hashtagGroupId: id)
            self.hashtagGroupList = hashtagRepository.selectAllHashtagGroups()
            completionHandler(true)
        })

        let editTitle = "Edit"
        let editAction = UIContextualAction(style: .normal, title: editTitle, handler: { (action, view, completionHandler) in
            // Create an alert controller with a textfield
            let alert = UIAlertController(title: "Edit name", message: nil, preferredStyle: .alert)
            alert.addTextField()

            // prepoluate field with current name
            let hashtagGroup = self.hashtagGroupList[indexPath.row]
            alert.textFields?[0].text = hashtagGroup.name

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

            // [weak alert] means you want to use a local variable called `alert` inside
            // of the closure with a weak reference so it is released after execution
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] _ in

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
                if self.hashtagGroupList.contains(where: {
                    self.normalizeString($0.name) == self.normalizeString(name)
                }) {
                    // Create an alert controller with a textfield
                    let uniqueAlert = UIAlertController(title: "Name must be unique!", message: nil, preferredStyle: .alert)
                    uniqueAlert.addAction(UIAlertAction(title: "Ok", style: .default))
                    self.present(uniqueAlert, animated: true, completion: nil)
                    return
                }

                hashtagRepository.updateHashtagGroupName(by: hashtagGroup.id ?? 0, name: name)
                self.hashtagGroupList = hashtagRepository.selectAllHashtagGroups()

                guard
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) as? HashtagGroupTableViewCell
                else {
                    fatalError("Could not downcast cell to HashtagGroupTableViewCell")
                }

                cell.hashtagGroupLabel.text = name
                self.tableView.reloadData()
            }))

            self.present(alert, animated: true, completion: nil)
            completionHandler(true)
        })


        //action.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return configuration
    }
}
