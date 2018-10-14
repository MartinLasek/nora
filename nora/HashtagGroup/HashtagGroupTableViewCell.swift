//
//  HashtagGroupTableViewCell.swift
//  nora
//
//  Created by Martin Lasek on 07.10.18.
//  Copyright © 2018 Martin Lasek. All rights reserved.
//

import UIKit

class HashtagGroupTableViewCell: UITableViewCell {

    // MARK: Properties

    // make cell aware of its group
    var hashtagGroup: HashtagGroup!

    // The HashtagGroupVC will assign a function to
    // display an alert that informs about the copying
    var onCopyHashtagCompletion: (() -> Void)!

    @IBOutlet weak var hashtagGroupLabel: UILabel!

    @IBAction func copyHashtags(_ sender: Any) {
        guard let group = hashtagGroup else {
            return
        }

        var hashtagString = group.hashtags.map({"#" + $0.name + " "}).joined()
        // remove whitespace before and after the string
        hashtagString = hashtagString.trimmingCharacters(in: .whitespaces)
        UIPasteboard.general.string = hashtagString

        onCopyHashtagCompletion()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
