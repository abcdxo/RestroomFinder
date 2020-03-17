//
//  MainTableView + DataSource.swift
//  Toilet
//
//  Created by Nick Nguyen on 3/15/20.
//  Copyright © 2020 Nick Nguyen. All rights reserved.
//

import UIKit
import MapKit

extension MainTableViewController {
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          
          return isSearch ? restroomController.searchedRestrooms.count : restroomController.restrooms.count
     
      }
      
      override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
          let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        
          let customRestroom = self.isSearch ? self.restroomController.searchedRestrooms[indexPath.row] : self.restroomController.restrooms[indexPath.row]
          
          
          
          cell.textLabel?.text  = customRestroom.name
          
          cell.detailTextLabel?.text = [customRestroom.street ,
                                        customRestroom.city ,
                                        customRestroom.state ,
                                        customRestroom.country].joined(separator: ",")
          
        
          
          
          return cell
      }
      
      
      override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          tableView.deselectRow(at: indexPath, animated: true)
          
         let customRestroom = self.isSearch ? self.restroomController.searchedRestrooms[indexPath.row] : self.restroomController.restrooms[indexPath.row]
          
          
          let startLocation = CLLocationCoordinate2D(latitude:  CLLocationDegrees(customRestroom.latitude),
                                                     longitude: CLLocationDegrees(customRestroom.longitude))
          
          let region = MKCoordinateRegion(center: startLocation,
                                          latitudinalMeters: 10000,
                                          longitudinalMeters: 10000)
        
        mapView.isPitchEnabled = true
        mapView.isZoomEnabled = true
        mapView.showsBuildings = true
        
        mapView.setRegion(region, animated: true)

       
      }
      
      override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
          
           return  UISwipeActionsConfiguration(actions:
                [makeArchiveContextualAction(forRowAt: indexPath)])
               
      }
      
      func makeArchiveContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
          let action = UIContextualAction(style: .normal, title: nil) { (action, _, completion) in
              
              let customRestroom = self.isSearch ? self.restroomController.searchedRestrooms[indexPath.row] : self.restroomController.restrooms[indexPath.row]
            

          
              self.restroomController.createRestroom(name: customRestroom.name,
                                                     street: customRestroom.street,
                                                     city: customRestroom.city,
                                                     state: customRestroom.state,
                                                     country: customRestroom.country,
                                                     longitude: customRestroom.longitude,
                                                     latitude: customRestroom.latitude)
              
              print(self.restroomController.favoriteRestrooms.count)
              
            self.showAlert(title: "Added restroom to favorites")
              completion(true)
          }
          action.image = UIImage(systemName: "heart")
          action.backgroundColor = UIColor(red: 186/255,
                                           green: 216/255,
                                           blue: 198/255,
                                           alpha: 1)
         return action
      }
}

extension UITableViewController {
    func showAlert(title:String) {
          let ac = UIAlertController(title: title,
                                     message: nil,
                                     preferredStyle: .alert)
          
          ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil ))
              
          present(ac, animated: true, completion: nil)
          
      }

}
