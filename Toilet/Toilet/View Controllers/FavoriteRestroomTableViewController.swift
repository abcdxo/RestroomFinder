//
//  FavoriteRestroomTableViewController.swift
//  Toilet
//
//  Created by Nick Nguyen on 3/14/20.
//  Copyright © 2020 Nick Nguyen. All rights reserved.
//

import UIKit
import MapKit

class FavoriteRestroomTableViewController: UITableViewController  {

  
    private let reuseCell = "Hello"
    
    //MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

            self.tableView.reloadData()
        
        let indexPath = IndexPath(row: RestroomController.shared.favoriteRestrooms.count - 1, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }

    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return RestroomController.shared.favoriteRestrooms.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseCell, for: indexPath)
        
        let currentRestroom = RestroomController.shared.favoriteRestrooms[indexPath.row]
        
        cell.textLabel?.text = currentRestroom.name
        cell.detailTextLabel?.text = [currentRestroom.street,
                                      currentRestroom.city,
                                      currentRestroom.state,
                                      currentRestroom.country].joined(separator: ",")
        
        cell.imageView?.image = UIImage(systemName: "heart.circle.fill")
        cell.setNeedsLayout()
        
        return cell
    }
 
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentRestroom = RestroomController.shared.favoriteRestrooms[indexPath.row]
        
        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(currentRestroom.latitude!),
                                                longitude: CLLocationDegrees(currentRestroom.longitude!))
      
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
        
        mapItem.name = currentRestroom.name
    
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let label = UILabel()
        
        label.text = "No favorite restrooms to display"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(label)
      
        NSLayoutConstraint.activate( [
            
            label.centerXAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerYAnchor)
            
        ])
        
        return label
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return RestroomController.shared.favoriteRestrooms.count == 0 ? 400 : 0
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let currentRestroom = RestroomController.shared.favoriteRestrooms[indexPath.row]
         
            RestroomController.shared.deleteEvent(restroom: currentRestroom)
               tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}
