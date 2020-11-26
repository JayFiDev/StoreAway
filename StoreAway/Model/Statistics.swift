//
//  Statistics.swift
//  StoreAway
//
//  Created by Jürgen Fink on 26.11.20.
//

import Foundation

struct Stats : Hashable {
  var filetypes : [String]
  var numberOfFiles: Int
  var size : UInt64
  var sizeString : String
}
