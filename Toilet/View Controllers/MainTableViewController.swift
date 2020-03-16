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
extension UITableViewController {
    func showAlert() {
          let ac = UIAlertController(title: "Added restroom to favorites",
                                     message: nil,
                                     preferredStyle: .alert)
          
          ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil ))
              
          present(ac, animated: true, completion: nil)
          
      }

}


protocol MainTableViewControllerDelegate: AnyObject {
    func didGetNewRestroom(restroom: Restroom)
}


class MainTableViewController: UITableViewController , UITabBarControllerDelegate {
    
       let reuseID = "ToiletCell"
    lazy var searchBar : UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Search for location"
        search.barStyle = .default
        return search
    }()
    
    let restroomController = RestroomController.shared
    var isSearch = false
    
   
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
          
            restroomController.fetchRestRoom(lat: locationManager.location?.coordinate.latitude ?? 40.730610 , long: locationManager.location?.coordinate.longitude ??  -73.935242) { (restroom, _) in
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
                 
           
                }
            }
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
             restroomController.fetchRestRoom(lat: locationManager.location?.coordinate.latitude ?? 40.730610 , long: locationManager.location?.coordinate.longitude ??  -73.935242) { (restroom, _) in
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
                restroomController.fetchRestRoom(lat: locationManager.location?.coordinate.latitude ?? 40.730610 , long: locationManager.location?.coordinate.longitude ??  -73.935242) { (restroom, _) in
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
             mapView.showsUserLocation = true
        
            mapView.setRegion(coordinateRegion, animated: true)
            locationManager.stopUpdatingLocation()

        }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
          print("Failed to find user's location: \(error.localizedDescription)")
      }
      
}
extension  MainTableViewController: UISearchBarDelegate {
      func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

      }
 
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else { return }
        searchBar.endEditing(true)
        isSearch = true
        
        
        self.restroomController.searchRestroom(searchTerm: searchTerm) { (restroom, _) in
            DispatchQueue.main.async {
                
                self.restroomController.searchedRestrooms.forEach { (restroom) in
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate.latitude = CLLocationDegrees(restroom.latitude)
                    annotation.coordinate.longitude = CLLocationDegrees(restroom.longitude)
                    annotation.title = restroom.name
                    annotation.subtitle = "View directions"
                    self.mapView.addAnnotation(annotation)
                    self.tableView.reloadData()
                }
                
                
                DispatchQueue.main.async {
                    self.locationManager.startUpdatingLocation()
                    self.tableView.reloadData()
                }
        
            }
        }
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
        }
        
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        tableView.reloadData()
    }
    
      }

