//
//  File.swift
//  Toilet
//
//  Created by Nick Nguyen on 3/13/20.
//  Copyright © 2020 Nick Nguyen. All rights reserved.
//

import Foundation

struct Restroom : Codable, Equatable {
  
  enum CodingKeys: String, CodingKey {
    case name
    case street
    case city
    case state
    case country
    case longitude
    case latitude
  }
  
  let name: String
  let street: String
  let city: String
  let state: String
  let country: String
  let longitude: Float?
  let latitude: Float?
  
}
