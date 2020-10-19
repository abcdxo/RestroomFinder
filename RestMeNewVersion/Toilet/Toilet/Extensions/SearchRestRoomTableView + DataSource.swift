//
//  MainTableView + DataSource.swift
//  Toilet
//
//  Created by Nick Nguyen on 3/15/20.
//  Copyright © 2020 Nick Nguyen. All rights reserved.
//

import UIKit
import MapKit

// MARK: - Data source & delegate 
extension SearchRestroomTableViewController {

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    return isSearch ? restroomController.searchedRestrooms.count : restroomController.restrooms.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)

    let customRestroom = self.isSearch ? self.restroomController.searchedRestrooms[indexPath.row] : self.restroomController.restrooms[indexPath.row]

    cell.textLabel?.text  = customRestroom.name
    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)

    cell.detailTextLabel?.text = [customRestroom.street,
                                  customRestroom.city,
                                  customRestroom.state,
                                  customRestroom.country].joined(separator: ",")

    let point = MKMapPoint(CLLocationCoordinate2D(latitude: CLLocationDegrees(customRestroom.latitude!),
                                                  longitude: CLLocationDegrees(customRestroom.longitude!)))

    guard let double = userDistance(from: point) else { fatalError("Are you on simulator?") }

    let miles = double / 1609.344
    let string = String(miles.roundToDecimal(1)) // convert to miles

    cell.detailTextLabel?.text = "\(string) miles away"
    cell.detailTextLabel?.textColor = .gray

    return cell
  }


  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let customRestroom = self.isSearch ? self.restroomController.searchedRestrooms[indexPath.row] : self.restroomController.restrooms[indexPath.row]


    let startLocation = CLLocationCoordinate2D(latitude:  CLLocationDegrees(customRestroom.latitude!),
                                               longitude: CLLocationDegrees(customRestroom.longitude!))

    let region = MKCoordinateRegion(center: startLocation,
                                    latitudinalMeters: 10000,
                                    longitudinalMeters: 10000)

    mapView.isPitchEnabled = true
    mapView.isZoomEnabled = true
    mapView.showsBuildings = true

    mapView.setRegion(region, animated: true)

    let annotation = mapView.annotations.filter{ $0.title == customRestroom.name }.first!
    mapView.selectAnnotation(annotation, animated: true)

  }

  override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

    return  UISwipeActionsConfiguration(actions:
                                          [makeArchiveContextualAction(forRowAt: indexPath)])

  }
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }

  func makeArchiveContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
    let action = UIContextualAction(style: .normal, title: nil) { (action, _, completion) in

      let customRestroom = self.isSearch ? self.restroomController.searchedRestrooms[indexPath.row] : self.restroomController.restrooms[indexPath.row]

      self.restroomController.createRestroom(name: customRestroom.name,
                                             street: customRestroom.street,
                                             city: customRestroom.city,
                                             state: customRestroom.state,
                                             country: customRestroom.country,
                                             longitude: customRestroom.longitude!,
                                             latitude: customRestroom.latitude!)

      completion(true)
    }
    action.image = UIImage(systemName: "heart")
    action.backgroundColor = .customGreen
    return action
  }
}

