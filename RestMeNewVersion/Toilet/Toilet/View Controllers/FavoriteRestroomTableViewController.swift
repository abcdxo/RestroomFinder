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

  private let reuseCell = "CellIdentifier"

  //MARK:- View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.tableView.reloadData()
  }

  // MARK: - Table view data source

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    return RestroomController.sharedInstance.favoriteRestrooms.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: reuseCell, for: indexPath)

    let currentRestroom = RestroomController.sharedInstance.favoriteRestrooms[indexPath.row]

    cell.textLabel?.text = currentRestroom.name
    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
    cell.detailTextLabel?.text = [currentRestroom.street,
                                  currentRestroom.city,
                                  currentRestroom.state,
                                  currentRestroom.country].joined(separator: ",")
    cell.detailTextLabel?.textColor = .gray
    cell.imageView?.image = UIImage(systemName: "heart.circle.fill")
    cell.setNeedsLayout()

    return cell
  }

  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    let currentRestroom = RestroomController.sharedInstance.favoriteRestrooms[indexPath.row]

    let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(currentRestroom.latitude!),
                                            longitude: CLLocationDegrees(currentRestroom.longitude!))

    let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))

    mapItem.name = currentRestroom.name

    mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
  }


  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let label = UILabel()
    label.text = "No favorite restrooms to display"
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.boldSystemFont(ofSize: 18)
    view.addSubview(label)

    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.topAnchor,constant: 16),
      label.centerXAnchor.constraint(equalTo: tableView.centerXAnchor)
    ])

    return label
  }

  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return RestroomController.sharedInstance.favoriteRestrooms.count == 0 ? 150 : 0
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {

      let currentRestroom = RestroomController.sharedInstance.favoriteRestrooms[indexPath.row]
      RestroomController.sharedInstance.deleteEvent(restroom: currentRestroom)
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }
  }
}
