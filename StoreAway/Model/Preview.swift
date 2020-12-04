//
//  Preview.swift
//  StoreAway
//
//  Created by Jürgen Fink on 26.11.20.
//

import Foundation

struct Previews : Hashable {
  var map : Mapping
  var folder : [Folder] 
  
}

struct Folder : Hashable, Codable, Identifiable {
  var id : UUID = UUID()
  var path : URL
  var files: [File]
}



struct File: Hashable, Codable, Identifiable {
  var id : UUID = UUID()
  var path : URL
  var relativePath: String
  var filename : String
  var filetype : String
}

