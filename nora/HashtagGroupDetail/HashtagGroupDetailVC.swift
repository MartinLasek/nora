//
//  HashtagGroupDetailVC.swift
//  nora
//
//  Created by Martin Lasek on 06.10.18.
//  Copyright © 2018 Martin Lasek. All rights reserved.
//

import UIKit

class HashtagGroupDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    let cellIdentifier = "hashtagGroupDetailCell"
    var hashtagGroup: HashtagGroup!

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
        return hashtagGroup.hashtags.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HashtagGroupDetailTableViewCell
        else {
            fatalError("No cell with identifier 'HashtagGroup' found")
        }

        let hashtag = hashtagGroup.hashtags[indexPath.row]

        cell.hashtagLabel.text = "#" + hashtag.name
        cell.hashtagUsageLabel.text = String(hashtag.usages)

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? HashtagSearchVC {
            vc.hashtagGroup = hashtagGroup
            vc.delegate = self
        }
    }

    func add(hashtags: [Hashtag]) {
        hashtagGroup.hashtags.append(contentsOf: hashtags)
        self.tableView.reloadData()
    }
}
