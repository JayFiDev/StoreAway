//
//  Statistics.swift
//  StoreAway
//
//  Created by Jürgen Fink on 26.11.20.
//

import Foundation

struct Stats: Hashable {

  var fileExtensions: [String]?
  var fileType: Type?
  var isCustom: Bool

  var numberOfFiles: Int
  var size: UInt64
  var sizeString: String
}
