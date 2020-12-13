//
//  Mapping.swift
//  StoreAway
//
//  Created by JayFi on 14.11.20.
//

import Foundation

struct Mapping: Hashable, Codable, Identifiable {

  var id: UUID
  var fileExtensions: [String]?
  var fileType: Type?
  var path: URL
  var isCustom: Bool

  init(path: URL, fileExtensions: [String]) {
    id = UUID()
    self.fileExtensions = fileExtensions
    self.fileType = nil
    self.path = path
    isCustom = true
  }

  init(id: UUID, path: URL, fileExtensions: [String]) {
    self.id = id
    self.fileExtensions = fileExtensions
    self.fileType = nil
    self.path = path
    isCustom = true
  }

  init(path: URL, fileType: Type) {
    id = UUID()
    self.fileExtensions = nil
    self.fileType = fileType
    self.path = path
    isCustom = false
  }

  init(id: UUID, path: URL, fileType: Type) {
    self.id = id
    self.fileExtensions = nil
    self.fileType = fileType
    self.path = path
    isCustom = false
  }

}
