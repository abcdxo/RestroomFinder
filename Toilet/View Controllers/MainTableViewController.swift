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


//TODO:
// Show blue dot current user
// Show detail annotation when tap on table view
// Use UITabBarControllerDelegate

protocol MainTableViewControllerDelegate: AnyObject {
    func didGetNewRestroom(restroom: Restroom)
}


class MainTableViewController: UITableViewController , UITabBarControllerDelegate {
    
    
    lazy var searchBar : UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Search for location"
        search.barStyle = .default
        return search
    }()
    
    let restroomController = RestroomController.shared
    
    
    private let reuseID = "ToiletCell"
    var locationManager = CLLocationManager()
    var location : CLLocationCoordinate2D?
    
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
                  mapView.isZoomEnabled = true
                  mapView.isScrollEnabled = true
                  mapView.showsLargeContentViewer = true
        }
    }

    private func setupNavBar() {
        
        navigationItem.titleView = searchBar
        navigationItem.leftBarButtonItem =   UIBarButtonItem(image: UIImage(systemName: "mappin.and.ellipse"), style: .done, target: self, action: #selector(handleTap))
    }
    
    
    //MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
          
            restroomController.fetchRestRoom(lat: location?.latitude ?? 40.730610 , long: location?.longitude ??  -73.935242) { (restroom, _) in
                DispatchQueue.main.async {
                    self.restroomController.restrooms.forEach { (restroom) in
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate.latitude = CLLocationDegrees(restroom.latitude)
                        annotation.coordinate.longitude = CLLocationDegrees(restroom.longitude)
                        annotation.title = restroom.name
                        annotation.subtitle = "View directions"
                        self.mapView.addAnnotation(annotation)
                        self.tableView.reloadData()
                    }
                    
                    self.locationManager.startUpdatingLocation()
                }}
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        searchBar.delegate = self
        checkLocationServices()
        setupNavBar()
    }
    func setUpLocationManager() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy  = kCLLocationAccuracyBest
        
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setUpLocationManager()
            checkLocationAuthorization()
        }
    }
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                // Do map stuff

                   locationManager.startUpdatingLocation()
             
                locationManager.requestWhenInUseAuthorization()
                
            break
            case .denied:
                //Show alert instructing them how to turn on permissions
//                locationManager.requestWhenInUseAuthorization()
            break
            case .notDetermined:
//                locationManager.requestWhenInUseAuthorization()
            break
            case .restricted:
                // Show an alert letting them know what's up
            break
            case .authorizedAlways:
            break
            default:
            break
        }
    }
    
    
    @objc func handleTap() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {

//         if let vc = viewController as? FavoriteRestroomTableViewController {
//            vc.delegate = self
//            vc.restroomController = restroomController
//            print("Hello World")
//         }

     }
    
    //MARK:- Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     
        return restroomController.restrooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath)
        
        let currentRestroom = restroomController.restrooms[indexPath.row]
        
        cell.textLabel?.text  = restroomController.restrooms[indexPath.row].name
        
        cell.detailTextLabel?.text = [currentRestroom.street ,
                                      currentRestroom.city ,
                                      currentRestroom.state ,
                                      currentRestroom.country].joined(separator: ",")
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let restroom = restroomController.restrooms[indexPath.row]
        
        
        let startLocation = CLLocationCoordinate2D(latitude:  CLLocationDegrees(restroom.latitude),
                                                   longitude: CLLocationDegrees(restroom.longitude))
        
        let region = MKCoordinateRegion(center: startLocation,
                                        latitudinalMeters: 10000,
                                        longitudinalMeters: 10000)
        
        mapView.setRegion(region, animated: true)

     
    }
    
  
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
         return  UISwipeActionsConfiguration(actions:
              [makeArchiveContextualAction(forRowAt: indexPath)])
             
    }
    
    func makeArchiveContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: nil) { (action, _, completion) in
            
            let restroom = self.restroomController.restrooms[indexPath.row]
        
            self.restroomController.createRestroom(name: restroom.name,
                                                   street: restroom.street,
                                                   city: restroom.city,
                                                   state: restroom.state,
                                                   country: restroom.country,
                                                   longitude: restroom.longitude,
                                                   latitude: restroom.latitude)
            
            print(self.restroomController.favoriteRestrooms.count)
            
            self.showAlert()
            completion(true)
        }
        action.image = UIImage(systemName: "heart")
        action.backgroundColor = UIColor(red: 186/255, green: 216/255, blue: 198/255, alpha: 1)
       return action
    }
    
    private func showAlert() {
        let ac = UIAlertController(title: "Added restroom to favorites",
                                   message: nil,
                                   preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil ))
            
        present(ac, animated: true, completion: nil)
        
    }

  
}

extension MainTableViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

           let identifier = "Restroom"
           
           var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
           
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Open Apple map
        
        let coordinate = CLLocationCoordinate2DMake(mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        if let annotation = view.annotation, let name = annotation.title {
            mapItem.name = "\(name ?? "...")"
        }
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])

     }
    
}


extension MainTableViewController: CLLocationManagerDelegate {

      func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let location = locations.first!
            let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
//             mapView.showsUserLocation = true
        
            mapView.setRegion(coordinateRegion, animated: true)
            locationManager.stopUpdatingLocation()

        }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
          print("Failed to find user's location: \(error.localizedDescription)")
      }
      
}
extension  MainTableViewController: UISearchBarDelegate {
      func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//          if searchText == "" {
//            restroomController.searchedRestrooms.removeAll()
//              tableView.reloadData()
//          }
      }
 
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        
        // If search bar empty show nothing
        //          if searchTerm.isEmpty {
        //              DispatchQueue.main.async {
        ////                  self.restroomController.searchedRestrooms.removeAll()
        //                  self.tableView.reloadData()
        //              }
        //          }
        restroomController.searchRestroom(searchTerm: searchTerm) { (restroom, _) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        
    }
    
    
      }

