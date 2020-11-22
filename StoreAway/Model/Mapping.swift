//
//  Mapping.swift
//  StoreAway
//
//  Created by JayFi on 14.11.20.
//

import Foundation

struct Mapping: Hashable, Codable, Identifiable {
  
  var id : UUID
  var name : [String]
  var path : URL
  

  
}

