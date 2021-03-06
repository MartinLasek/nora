//
//  HashtagSearchVC.swift
//  nora
//
//  Created by Martin Lasek on 07.10.18.
//  Copyright © 2018 Martin Lasek. All rights reserved.
//

import UIKit

class HashtagSearchVC: UIViewController {

    // MARK: Properties

    var hashtagsOfSearchResult = [Hashtag]()
    var selectedHashtags = [Hashtag]()
    let instagramClient = InstagramClient()

    // Taking care of storing/retrieving data to/from disk
    let hashtagRepository = HashtagRepository()

    // assigned by prepare:segue in HashtagGroupDetail
    var hashtagGroup: HashtagGroup!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self

        // Dismisses Keyboard if tapped anywhere in the view
        let selector = #selector(UIView.endEditing(_:))
        let gestureRecognizer = UITapGestureRecognizer(target: self.view, action: selector)

        // Set to `false` because otherwise table cell touches
        // are eaten by the gestureRecognizer
        gestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(gestureRecognizer)

        // focus on search bar when view is loaded
        self.searchBar.becomeFirstResponder()
    }

    @IBAction func cancelButton(_ sender: Any) {

        if !selectedHashtags.isEmpty {
            // Create an alert controller with a textfield
            let alert = UIAlertController(
                title: "You have selected Hashtags",
                message: "Do you want to cancel anyway?",
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: "No", style: .cancel))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))

            self.present(alert, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func saveButton(_ sender: Any) {
        for hashtag in selectedHashtags {
            hashtagRepository.insert(hashtag)
        }
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: Searchbar

extension HashtagSearchVC: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let adjustedSearchText = urlEncode(from: searchText)

        if adjustedSearchText.isEmpty {
            hashtagsOfSearchResult = []
            self.tableView.reloadData()
        } else {

            self.instagramClient.searchInstagram(for: adjustedSearchText, completion: { searchResult in
                guard let hashtagGroupId = self.hashtagGroup.id else {
                    print("`hashtagGroup` has no id. It is needed to instantiate `Hashtag` from the search result")
                    return
                }

                // sorted: puts the hashtag with the same name es the search text to the top
                self.hashtagsOfSearchResult = searchResult.data.map {
                    Hashtag(name: $0.name, usages: $0.mediaCount, hashtagGroupId: hashtagGroupId)
                }.sorted(by: {(hashtagOne, _) in hashtagOne.name == adjustedSearchText})

                self.tableView.reloadData()
            })
        }
    }

    // Dismisses Keyboard when hitting "done".
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }

    // - transforms to lowercase
    // - encodes special characters suitable for url
    func urlEncode(from searchText: String) -> String {
        var result = searchText
        result = result.lowercased()

        if let urlEncoded = result.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            result = urlEncoded
        }

        return result
    }
}

// MARK: Tableview

extension HashtagSearchVC: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hashtagsOfSearchResult.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hashtag = hashtagsOfSearchResult[indexPath.row]

        // nothing shall happen if hashtag is part of hashtagGroup already
        if hashtagGroup.hashtags.contains(where: {h in h.name == hashtag.name}) {
            return
        }

        // if hashtag is in selectedHashtags list remove, otherwise add
        if nil != selectedHashtags.first { $0.name == hashtag.name } {
            selectedHashtags.removeAll(where: { $0.name == hashtag.name })
        } else {
            selectedHashtags.append(hashtag)
        }

        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier = "hashtagSearchCell"
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: cellIdentifier,
                for: indexPath
            ) as? HashtagSearchTableViewCell
        else {
            fatalError("No cell with identifier '\(cellIdentifier)' found")
        }

        // Early return since "index out of range" once occured here.
        if hashtagsOfSearchResult.count <= indexPath.row {
            return cell
        }

        let hashtag = hashtagsOfSearchResult[indexPath.row]

        // resetting the state because if it was `selected` and is not in
        // the list `selectedHashtags` it won't gain the `none` state
        hashtag.state = Hashtag.State.none

        // asign `added` state
        if nil != hashtagGroup.hashtags.first { $0.name == hashtag.name } {
            hashtag.state = Hashtag.State.added
        }

        // asign `selected` state
        if nil != selectedHashtags.first { $0.name == hashtag.name } {
            hashtag.state = Hashtag.State.selected
        }

        cell.hashtagSearchLabel.text = "#" + hashtag.name
        cell.hashtagSearchUsageLabel.text = hashtag.usages.dotNotation()
        cell.hashtagSearchStateLabel.text = hashtag.state.rawValue

        return cell
    }
}
