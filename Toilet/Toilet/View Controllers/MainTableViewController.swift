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
// Slow networking call

class MainTableViewController: UITableViewController , UITabBarControllerDelegate {
    
    
    //MARK:- Properties
    
    lazy private var locationManager : CLLocationManager = {
           let lm = CLLocationManager()
           lm.delegate = self
           lm.desiredAccuracy  = kCLLocationAccuracyBest
           lm.activityType = .fitness
           return lm
       }()

    lazy var searchBar : UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Search for location"
        search.barStyle = .default
        search.enablesReturnKeyAutomatically = true
        search.delegate = self
        return search
    }()
    
    public let restroomController = RestroomController.shared
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
    
    lazy var indicator = UIActivityIndicatorView()

    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.center = self.mapView.center
        self.tableView.addSubview(indicator)
    }
    

    //MARK:- View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        setupNavBar()
        locationManager.requestWhenInUseAuthorization()
        
    }
   
    private func setupNavBar() {
        
        navigationItem.titleView = searchBar
        
        navigationItem.leftBarButtonItem =   UIBarButtonItem(image: UIImage(systemName: "mappin.and.ellipse")
            , style: .done,
              target: self,
              action: #selector(handleTap))
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
//                restroomController.fetchRestRoom(lat: locationManager.location?.coordinate.latitude ?? 40.730610 ,
//                                                 long: locationManager.location?.coordinate.longitude ??  -73.935242) { (restroom, _) in
//                                                    DispatchQueue.main.async {
//
//                                                        self.restroomController.restrooms.forEach { (restroom) in
//
//                                                            let annotation = MKPointAnnotation()
//                                                            annotation.coordinate.latitude = CLLocationDegrees(restroom.latitude!)
//                                                            annotation.coordinate.longitude = CLLocationDegrees(restroom.longitude!)
//                                                            annotation.title = restroom.name
//                                                            annotation.subtitle = "View directions"
//                                                            self.mapView.addAnnotation(annotation)
//                                                            self.tableView.reloadData()
//                                                        }
//
//                                                    }
//
//                }
                
                
                break
            case .denied:
                showAlert(title: "Please turn on your GPS in Settings so we can show you the nearest restrooms.")
                locationManager.requestWhenInUseAuthorization()
                break
            case .notDetermined:
        
                break
            case .restricted:
                // Show an alert letting them know what's up
                break
            case .authorizedAlways:
//                restroomController.fetchRestRoom(lat: locationManager.location?.coordinate.latitude ?? 40.730610 , long: locationManager.location?.coordinate.longitude ??  -73.935242) { (restroom, _) in
//                    DispatchQueue.main.async {
//
//                        self.restroomController.restrooms.forEach { (restroom) in
//
//                            let annotation = MKPointAnnotation()
//                            annotation.coordinate.latitude = CLLocationDegrees(restroom.latitude!)
//                            annotation.coordinate.longitude = CLLocationDegrees(restroom.longitude!)
//                            annotation.title = restroom.name
//                            annotation.subtitle = "View directions"
//                            self.mapView.addAnnotation(annotation)
//                            self.tableView.reloadData()
//                        }
//
//                        self.locationManager.startUpdatingLocation()
//
//                    }}
                self.locationManager.startUpdatingLocation()
            default:
                break
        }
    }
    
    @objc private func handleTap() {
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
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])

     }

}


extension MainTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            restroomController.fetchRestRoom(lat: locationManager.location?.coordinate.latitude ?? 40.730610 ,
                                                       long: locationManager.location?.coordinate.longitude ??  -73.935242) { (restroom, _) in
                                                          DispatchQueue.main.async {
                                                              
                                                              self.restroomController.restrooms.forEach { (restroom) in
                                                                  
                                                                  let annotation = MKPointAnnotation()
                                                                  annotation.coordinate.latitude = CLLocationDegrees(restroom.latitude!)
                                                                  annotation.coordinate.longitude = CLLocationDegrees(restroom.longitude!)
                                                                  annotation.title = restroom.name
                                                                  annotation.subtitle = "View directions"
                                                                  self.mapView.addAnnotation(annotation)
                                                                  self.tableView.reloadData()
                                                              }
                                                              
                                                          }
                                                          
                      }
            locationManager.startUpdatingLocation()
        }
        else  if status == .authorizedAlways {
            restroomController.fetchRestRoom(lat: locationManager.location?.coordinate.latitude ?? 40.730610 ,
                                             long: locationManager.location?.coordinate.longitude ??  -73.935242) { (restroom, _) in
                                                DispatchQueue.main.async {
                                                    
                                                    self.restroomController.restrooms.forEach { (restroom) in
                                                        
                                                        let annotation = MKPointAnnotation()
                                                        annotation.coordinate.latitude = CLLocationDegrees(restroom.latitude!)
                                                        annotation.coordinate.longitude = CLLocationDegrees(restroom.longitude!)
                                                        annotation.title = restroom.name
                                                        annotation.subtitle = "View directions"
                                                        self.mapView.addAnnotation(annotation)
                                                        self.tableView.reloadData()
                                                    }
                                                    
                                                }
                                                
            }
            locationManager.startUpdatingLocation()
        } else if status == .denied {
            showAlert(title: "Please turn on GPS so we can show you nearest restrooms.")
            locationManager.requestWhenInUseAuthorization()
        }
    }

      func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let location = locations.first!
            let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
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
extension  MainTableViewController: UISearchBarDelegate {
 
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       guard let searchTerm = searchBar.text else { return }
        
        searchBar.endEditing(true)
        isSearch = true
        
        activityIndicator()
        indicator.startAnimating()
        indicator.backgroundColor = .white
        
        restroomController.restrooms.removeAll()
        tableView.reloadData()
        
            self.restroomController.searchRestroom(searchTerm: searchTerm) { (restroom, _) in
                
                      DispatchQueue.main.async {
                        
                        self.indicator.stopAnimating()
                        self.indicator.hidesWhenStopped = true
                        
                         
                        
                          self.restroomController.searchedRestrooms.forEach { (restroom) in

                              let annotation = MKPointAnnotation()
                            annotation.coordinate.latitude = CLLocationDegrees(restroom.latitude ?? 0.0)
                            annotation.coordinate.longitude = CLLocationDegrees(restroom.longitude ?? 0.0)
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

   
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            tableView.reloadData()
          
        }
    
      }

}
