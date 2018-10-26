//
//  HashtagGroupDetailVC.swift
//  nora
//
//  Created by Martin Lasek on 06.10.18.
//  Copyright © 2018 Martin Lasek. All rights reserved.
//

import UIKit

class HashtagGroupDetailVC: UIViewController {
    
    // MARK: Properties
    let cellIdentifier = "hashtagGroupDetailCell"
    var hashtagGroup: HashtagGroup!

    // Taking care of storing/retrieving data to/from disk
    let hashtagRepository = HashtagRepository()

    @IBOutlet weak var tableView: UITableView!

    override func viewWillAppear(_ animated: Bool) {
        loadHashtagGroup()
        sortHashtags()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false

        self.navigationItem.title = self.hashtagGroup.name
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? HashtagSearchVC {
            vc.hashtagGroup = hashtagGroup
        }
    }

    func loadHashtagGroup() {
        guard let id = hashtagGroup.id else {
            return
        }
        hashtagGroup = hashtagRepository.selectHashtagGroup(by: id)
        self.tableView.reloadData()
    }

    func sortHashtags() {
        hashtagGroup.hashtags.sort(by: {$0.usages > $1.usages})
        self.tableView.reloadData()
    }
}

// MARK: Tableview

extension HashtagGroupDetailVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hashtagGroup.hashtags.count
    }

    // see: https://www.hackingwithswift.com/example-code/uikit/how-to-add-a-section-header-to-a-table-view
    // google search: https://www.google.de/search?q=ios+tableview+section+header&oq=ios+tableview+section+header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Hashtags: \(hashtagGroup.hashtags.count)"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HashtagGroupDetailTableViewCell
        else {
            fatalError("No cell with identifier 'HashtagGroup' found")
        }

        let hashtag = hashtagGroup.hashtags[indexPath.row]

        cell.hashtagLabel.text = "#" + hashtag.name
        cell.hashtagUsageLabel.text = hashtag.usages.dotNotation()

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let hashtag = self.hashtagGroup.hashtags[indexPath.row]
            guard let hashtagId = hashtag.id else {
                return
            }
            guard let hashtagGroupId = self.hashtagGroup.id else {
                return
            }

            // remove from database
            hashtagRepository.removeHashtag(by: hashtagId)
            // retrieve from database
            hashtagGroup = hashtagRepository.selectHashtagGroup(by: hashtagGroupId)

            // it must come after deleting from database
            // becuase hashtagGroupList must at this point have the same number
            // of entries like the rows after the deletion happened
            //
            // .reloadData() is needed to update the section value (hashtag count)
            // and sine it would interrupt the delete animation before it's finished
            // we use CATransaction to do it after the animation is done
            CATransaction.begin()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            CATransaction.setCompletionBlock({
                self.tableView.reloadData()
                self.sortHashtags()
            })
            CATransaction.commit()
        }
    }
}
