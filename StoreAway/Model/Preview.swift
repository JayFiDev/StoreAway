//
//  Preview.swift
//  StoreAway
//
//  Created by Jürgen Fink on 26.11.20.
//

import Foundation

struct Previews : Hashable {
  var map : Mapping
  var pathlist : [PashList]
  
}

struct PashList : Hashable {
  var oldPath : URL
  var newPath : URL
}
