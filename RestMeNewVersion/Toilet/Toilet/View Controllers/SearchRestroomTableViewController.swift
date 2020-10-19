//
//  ViewController.swift
//  Toilet
//
//  Created by Nick Nguyen on 3/13/20.
//  Copyright © 2020 Nick Nguyen. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SVProgressHUD

class SearchRestroomTableViewController: UITableViewController , UITabBarControllerDelegate {

  //MARK:- Properties

  lazy private var locationManager: CLLocationManager = {
    let lm = CLLocationManager()
    lm.delegate = self
    lm.desiredAccuracy  = kCLLocationAccuracyBest
    lm.activityType = .fitness
    return lm
  }()

  lazy var searchBar: UISearchBar = {
    let search = UISearchBar()
    search.placeholder = "Search by city name"
    search.barStyle = .default
    search.enablesReturnKeyAutomatically = true
    search.delegate = self
    return search
  }()

  public let restroomController = RestroomController.sharedInstance
  public var isSearch = false
  var location : CLLocationCoordinate2D?
  let reuseID = "ToiletCell"


  //MARK:- IBOutlets

  @IBOutlet weak var mapView: MKMapView! {
    didSet {
      mapView.isZoomEnabled = true
      mapView.isScrollEnabled = true
      mapView.showsLargeContentViewer = true
      mapView.showsUserLocation = true
      mapView.delegate = self
    }
  }

  //MARK:- View Life Cycle
  @objc func showErrorAlert(_ notification: Notification) {
    switch notification.name {
      case .contained:
        showAlert(title: "This restroom is already added in Favorite Restroom!", preferredStyle: .alert)
      case .success:
        showAlert(title: "Added", preferredStyle: .alert)
      default:
        break
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemGray6
    NotificationCenter.default.addObserver(self, selector: #selector(showErrorAlert(_:)), name: .contained, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(showErrorAlert(_:)), name: .success, object: nil)
    checkLocationServices()
    setupNavBar()
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    let gesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
    mapView.addGestureRecognizer(gesture)
  }

  @objc func hideKeyboard() { searchBar.resignFirstResponder() }

  @IBAction func rightBarButtonTapped(_ sender: UIBarButtonItem) {
    searchBar.resignFirstResponder()
  }

  private func setupNavBar() {

    navigationItem.titleView = searchBar

    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "mappin.and.ellipse"),
                                                       style: .done,
                                                       target: self,
                                                       action: #selector(handleTap))
  }

  func userDistance(from point: MKMapPoint) -> Double? {
    guard let userLocation = locationManager.location else {
      return nil // User location unknown!
    }
    let pointLocation = CLLocation(
      latitude:  point.coordinate.latitude,
      longitude: point.coordinate.longitude
    )
    return userLocation.distance(from: pointLocation)
  }
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

    let label = UILabel()
    label.text = "No restrooms to display."
    label.font = UIFont.boldSystemFont(ofSize: 15)
    label.numberOfLines = 2
    return label
  }

  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return restroomController.restrooms.count == 0  && restroomController.searchedRestrooms.count == 0 ? 50 : 0
  }


  private func checkLocationServices() {
    if CLLocationManager.locationServicesEnabled() {
      checkLocationAuthorization()

    } else {
      locationManager.requestWhenInUseAuthorization()
    }
  }


  private func checkLocationAuthorization() {
    switch CLLocationManager.authorizationStatus() {
      case .authorizedWhenInUse:
        locationManager.startUpdatingLocation()
        break
      case .denied:
        showAlert(title: "Please turn on your GPS in Settings so we can show you the nearest restrooms.", preferredStyle: .alert)
        locationManager.requestWhenInUseAuthorization()
        break
      case .notDetermined:

        break
      case .restricted:
        // Show an alert letting them know what's up
        break
      case .authorizedAlways:

        self.locationManager.startUpdatingLocation()
      default:
        break
    }
  }

  @objc private func handleTap() {
    searchBar.resignFirstResponder()

    isSearch = false
    if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
      restroomController.refetchRestroom(lat: locationManager.location?.coordinate.latitude ?? 40.730610 ,
                                         long: locationManager.location?.coordinate.longitude ?? -73.935242) { (restroom, _) in

        self.restroomController.restrooms.forEach { (restroom) in

          let annotation = MKPointAnnotation()
          annotation.coordinate.latitude = CLLocationDegrees(restroom.latitude!)
          annotation.coordinate.longitude = CLLocationDegrees(restroom.longitude!)
          annotation.title = restroom.name
          annotation.subtitle = "View directions"
          self.mapView.addAnnotation(annotation)
          DispatchQueue.main.async {
            self.tableView.reloadData()
          }
        }
      }
      locationManager.startUpdatingLocation()
    } else {
      locationManager.requestWhenInUseAuthorization()
    }
  }
}

extension SearchRestroomTableViewController: MKMapViewDelegate {

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

    let identifier = "Restroom"

    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView

    if annotation is MKUserLocation {
      return nil
    }

    if annotationView == nil {
      annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
      annotationView?.canShowCallout = true
      annotationView?.pinTintColor = .red
      annotationView?.accessibilityActivate()
      annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

    } else {
      annotationView?.annotation = annotation
      annotationView?.animatesDrop = true
      annotationView?.canShowCallout = true

    }

    return annotationView
  }
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }


  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    // Open Apple map
    let coordinate = CLLocationCoordinate2DMake(mapView.centerCoordinate.latitude,
                                                mapView.centerCoordinate.longitude)

    let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate,
                                                   addressDictionary:nil))

    if let annotation = view.annotation, let name = annotation.title {
      mapItem.name = "\(name ?? "...")"
    }
    let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    ac.addAction(UIAlertAction(title: "Google Map", style: .default, handler: {  action in
      openGoogleMapToRestroom(lat: (coordinate.latitude), long:(coordinate.longitude), destinationName: mapItem.name!)
    }))
    ac.addAction(UIAlertAction(title: "Apple Map", style: .default, handler: { (action) in
      mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }))
    ac.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
    self.present(ac, animated: true, completion: nil)

  }
}
func openGoogleMapToRestroom(lat: CLLocationDegrees, long: CLLocationDegrees, destinationName: String) {
  // if GoogleMap installed
  if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
    UIApplication.shared.open(URL(string:
                                    "comgooglemaps://?saddr=&daddr=\(lat),\(long)&directionsmode=driving&destination=\(destinationName)")!)

  } else {
    // if GoogleMap App is not installed
    UIApplication.shared.open(URL(string:
                                    "https://maps.google.com/?q=@\(lat),\(long)")!)
  }
}

extension SearchRestroomTableViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

    if status == .authorizedWhenInUse || status == .authorizedAlways {
      locationManager.startUpdatingLocation()
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location = locations.first!
    let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)


    self.restroomController.fetchRestRoom(lat: self.locationManager.location?.coordinate.latitude ?? 40.730610 ,
                                          long: self.locationManager.location?.coordinate.longitude ??  -73.935242) { (restroom, _) in


      self.restroomController.restrooms.forEach { (restroom) in

        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = CLLocationDegrees(restroom.latitude!)
        annotation.coordinate.longitude = CLLocationDegrees(restroom.longitude!)
        annotation.title = restroom.name
        annotation.subtitle = "View directions"
        self.mapView.addAnnotation(annotation)
        DispatchQueue.main.async {
          self.tableView.reloadData()
        }
      }
    }
    mapView.setRegion(coordinateRegion, animated: true)
    locationManager.stopUpdatingLocation()

  }
  @objc func request(action: UIAlertAction) {
    self.locationManager.requestWhenInUseAuthorization()
  }
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Failed to find user's location: \(error.localizedDescription)")
    let ac = UIAlertController(title: "Please turn on GPS so we can show you the nearest restroom", message: nil, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: request(action:)))

    present(ac, animated: true, completion: {
      self.locationManager.requestWhenInUseAuthorization()
    })
  }
}
extension SearchRestroomTableViewController: UISearchBarDelegate {

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let searchTerm = searchBar.text else { return }

    searchBar.endEditing(true)
    isSearch = true

    SVProgressHUD.setDefaultStyle(.dark)
    SVProgressHUD.show(withStatus: "Searching...")

    restroomController.restrooms.removeAll()
    tableView.reloadData()

    self.restroomController.searchRestroom(searchTerm: searchTerm) { (restroom, _) in

      DispatchQueue.main.async {

        SVProgressHUD.dismiss()

        self.restroomController.searchedRestrooms.forEach { (restroom) in

          let annotation = MKPointAnnotation()
          annotation.coordinate.latitude = CLLocationDegrees(restroom.latitude ?? 0.0)
          annotation.coordinate.longitude = CLLocationDegrees(restroom.longitude ?? 0.0)
          annotation.title = restroom.name
          annotation.subtitle = "View directions"
          self.mapView.addAnnotation(annotation)

        }
        self.tableView.reloadData()
        self.locationManager.startUpdatingLocation()
      }
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
      tableView.reloadData()

    }
  }
}
