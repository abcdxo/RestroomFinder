//
//  Convenience + Ext.swift
//  Toilet
//
//  Created by Nick Nguyen on 3/19/20.
//  Copyright © 2020 Nick Nguyen. All rights reserved.
//

import UIKit
import MapKit
import MessageUI

extension UITableViewController {
    func showAlert(title:String) {
          let ac = UIAlertController(title: title,
                                     message: nil,
                                     preferredStyle: .alert)
          
          ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil ))
              
          present(ac, animated: true, completion: nil)
          
      }

}
extension SettingTableViewController : MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
       
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
