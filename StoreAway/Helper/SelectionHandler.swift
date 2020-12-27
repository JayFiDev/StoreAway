//
//  SelectionHandler.swift
//  StoreAway
//
//  Created by Jürgen Fink on 14.12.20.
//

import Foundation

class SelectionHandler: ObservableObject {

  @Published var selectionChanged: Bool = false
  @Published var selectedMapping: Mapping? {
    didSet {
      selectionChanged = selectedMapping != nil ? true : false
    }
  }
}
