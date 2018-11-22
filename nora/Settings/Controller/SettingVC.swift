//
//  SettingVC.swift
//  nora
//
//  Created by Martin Lasek on 09.11.18.
//  Copyright © 2018 Martin Lasek. All rights reserved.
//

import UIKit
import MessageUI

class SettingVC: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var feedbackButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        feedbackButton.layer.cornerRadius = 5
    }


    @IBAction func sendFeedback(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["noralasek-app@outlook.com"])
            mail.setMessageBody("<p>Hey Martin, here's my feedback!!</p>", isHTML: true)

            present(mail, animated: true)
        } else {
            let uniqueAlert = UIAlertController(title: "Seems like you have no email set up on your iPhone!", message: nil, preferredStyle: .alert)
            uniqueAlert.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(uniqueAlert, animated: true, completion: nil)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
