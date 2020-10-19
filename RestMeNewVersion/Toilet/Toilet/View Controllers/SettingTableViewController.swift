//
//  DetailViewController.swift
//  Toilet
//
//  Created by Nick Nguyen on 3/13/20.
//  Copyright © 2020 Nick Nguyen. All rights reserved.
//

import UIKit
import MessageUI

class SettingTableViewController: UITableViewController  {
  
  //MARK:- Properties
  
  private let mail = MFMailComposeViewController()
  
  //MARK:- Methods:
  private func sendEmail() {
    if MFMailComposeViewController.canSendMail() {
      
      mail.mailComposeDelegate = self
      mail.setToRecipients(["nicknguyenios14@gmail.com"])
      mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)
      
      present(mail, animated: true)
    } else {
      let ac = UIAlertController(title: "Error sending email",
                                 message: "Your device does not support email, please try again later.",
                                 preferredStyle: .alert)
      
      ac.addAction(UIAlertAction(title: "Cancel",
                                 style: .destructive,
                                 handler: nil))
      
      present(ac, animated: true)
    }
  }
  
  private func openTwitter() {
    
    let twitterUrl = URL(string: "twitter://user?screen_name=NickNguyen_14")!
    let twitterUrlWeb = URL(string: "https://www.twitter.com/NickNguyen_14")!
    
    if UIApplication.shared.canOpenURL(twitterUrl) {
      UIApplication.shared.open(twitterUrl,options: [:],completionHandler: nil)
    } else {
      
      UIApplication.shared.open(twitterUrlWeb,options: [:],completionHandler: nil)
    }
  }
  
  private func openAppleStore() {
    if let appStoreURL = URL(string: "https://apps.apple.com/us/developer/thinh-nguyen/id1475297118") {
      UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
    }
  }
  
  // MARK:- View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
  }
  
  
  @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
    dismiss(animated: true)
  }
  
  // MARK:- Table View Data Source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    tableView.deselectRow(at: indexPath, animated: true)
    
    switch indexPath.row {
      case 0:
        openTwitter()
      case 1:
        openAppleStore()
      case 2:
        sendEmail()
      default:
        break
    }
  }
}
