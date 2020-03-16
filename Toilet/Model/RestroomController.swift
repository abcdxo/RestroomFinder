//
//  RestroomController.swift
//  Toilet
//
//  Created by Nick Nguyen on 3/13/20.
//  Copyright © 2020 Nick Nguyen. All rights reserved.
//

import Foundation


///v1/restrooms/by_location?page=1&per_page=10&offset=0&ada=false&unisex=false&lat=37.33233141&lng=-122.23
class RestroomController {
    
    let jsonDecoder = JSONDecoder()
    static let shared = RestroomController()
    var baseURL = URL(string: "https://www.refugerestrooms.org/api")!
    var restrooms = [Restroom]()
    var favoriteRestrooms = [Restroom]()
    var searchedRestrooms = [Restroom]()
    
    init() {
        loadFromPersistentStore()
    }

    
    func fetchRestRoom(lat:Double,long:Double, completion: @escaping ([Restroom]?,Error?) -> Void ) {
         baseURL.appendPathComponent("v1/restrooms/by_location")
        let urlComponents = NSURLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        
      
             urlComponents?.queryItems =
                [
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "per_page", value: "10"),
                URLQueryItem(name: "offset", value: "0"),
                URLQueryItem(name: "ada", value: "false"),
                URLQueryItem(name: "unisex", value: "false"),
                URLQueryItem(name: "lat", value: String(lat)),
                URLQueryItem(name: "lng", value: String(long))
                ]
        
        guard let restRoomURL = urlComponents?.url else { return }
        let request = URLRequest(url: restRoomURL)
        print(restRoomURL)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print(error)
                completion(nil,error)
                return
            }
            
            guard response != nil else {
                print("No data")
                return 
            }
            
            guard let data = data  else { return }
 
            do {
                let restroom = try self.jsonDecoder.decode([Restroom].self, from: data)
                self.restrooms = restroom
                completion(restroom,nil)
            } catch let err as NSError {
                print(err)
            }

        }.resume()
        
    }
    
  private var restroomURL : URL? {
           let fm = FileManager.default
           guard let documentDirectory = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
           let eventURL = documentDirectory.appendingPathComponent("Restrooms.plist")
           return eventURL
       }
    
    private func saveToPersistStore() {
           guard let fileURL = restroomURL else { return }
           do {
                let encoder = PropertyListEncoder()
               let eventData = try encoder.encode(favoriteRestrooms)
               try eventData.write(to: fileURL)
           } catch  let err {
               print("Can't save events.Error : \(err)")
           }
          
       }
       
      private func loadFromPersistentStore() {
           guard let fileURL = restroomURL else { return }
           do {
               let restroomData = try Data(contentsOf: fileURL)
               let decoder = PropertyListDecoder()
               let decodedRestroom = try  decoder.decode([Restroom].self, from: restroomData)
               self.favoriteRestrooms = decodedRestroom
           } catch let err {
               print("Can't load Data , error: \(err)")
           }
       }
    
    
    func createRestroom( name: String, street: String, city: String, state: String, country: String,longitude:Float,latitude:Float)  {
        
     let restroom = Restroom(name: name,
                             street: street,
                             city: city,
                             state: state,
                             country: country,
                             longitude: longitude,
                             latitude: latitude)
        
        favoriteRestrooms.append(restroom)
        
        saveToPersistStore()
    }
    
    func deleteEvent(restroom: Restroom) {
        
          guard let restroom = favoriteRestrooms.firstIndex(of: restroom) else { return }
        
          favoriteRestrooms.remove(at: restroom)
          saveToPersistStore()
      }
    
    
    
//    https://www.refugerestrooms.org/api/v1/restrooms/search?page=1&per_page=10&offset=0&ada=true&unisex=true&query=London
//    https://www.refugerestrooms.org/api/v1/restrooms?page=1&per_page=10&offset=0&ada=true&unisex=true&query=London
    
    func searchRestroom(searchTerm: String , completion: @escaping ([Restroom]?,Error?) -> Void) {
        let searchURL = URL(string: "https://www.refugerestrooms.org/api/v1/restrooms/search")!
     
        let urlComponents = NSURLComponents(url: searchURL, resolvingAgainstBaseURL: false)
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "per_page", value: "10"),
            URLQueryItem(name: "offset", value: "0"),
            URLQueryItem(name: "ada", value: "true"),
            URLQueryItem(name: "unisex", value: "true"),
            URLQueryItem(name: "query", value: searchTerm)
        ]
        
        guard let searchedURL = urlComponents?.url else { return }
        let request = URLRequest(url: searchedURL)
  
        print(request)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let err = error  {
                print(err)
                completion(nil,err)
                return
            }
            
            guard let data = data else {
                NSLog("No data from sever")
                return
            }
           
         do {
            let restroom = try self.jsonDecoder.decode([Restroom].self, from: data)
                self.searchedRestrooms = restroom
                completion(restroom,nil)
            } catch let err {
                print(err)
            }

        }.resume()
      
    }
    
    
}


