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
    
    private func sendEmail() {
           if MFMailComposeViewController.canSendMail() {
               let mail = MFMailComposeViewController()
               mail.mailComposeDelegate = self
               mail.setToRecipients(["ptnguyen1901@gmail.com"])
               mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)

               present(mail, animated: true)
           } else {
             let ac = UIAlertController(title: "Error sending email", message: "Your device does not support email, please try again later.", preferredStyle: .alert)
             ac.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
             present(ac, animated: true)
           }
       }

 
   private func openTwitter() {

        let twitterUrl = URL(string: "twitter://user?screen_name=tonic4000")!
           let twitterUrlWeb = URL(string: "https://www.twitter.com/tonic4000")!
           if UIApplication.shared.canOpenURL(twitterUrl) {
              UIApplication.shared.open(twitterUrl, options: [:],completionHandler: nil)
           } else {
              UIApplication.shared.open(twitterUrlWeb, options: [:], completionHandler: nil)
           }
    }
    
    private func openAppleStore() {
        let urlStr = "https://apps.apple.com/us/developer/thinh-nguyen/id1475297118"
                   UIApplication.shared.open(URL(string: urlStr)!, options: [:], completionHandler: nil)
    }
    
    //MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        view.backgroundColor = .white

    }

    //MARK:- Table View Data Source
    
    
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
extension SettingTableViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
       
       if let _ = error {
           controller.dismiss(animated: true)
       }
       switch result {
       case .cancelled:
          controller.dismiss(animated: true)
       default:
          controller.dismiss(animated: true)
       }
     }
}
