//
//  OperationRecord.swift
//  StoreAway
//

import Foundation

enum TriggerSource: String, Codable {
  case manual
  case autoWatch
  case menuBar
}

struct OperationRecord: Codable, Identifiable, Hashable {
  var id: UUID = UUID()
  var date: Date
  var filesMoved: Int
  var filesCopied: Int
  var triggerSource: TriggerSource

  var totalFiles: Int { filesMoved + filesCopied }

  var sourceName: String {
    switch triggerSource {
    case .manual: return "Manual"
    case .autoWatch: return "Auto"
    case .menuBar: return "Menu bar"
    }
  }

  var sourceSymbol: String {
    switch triggerSource {
    case .manual: return "hand.tap"
    case .autoWatch: return "wand.and.stars"
    case .menuBar: return "menubar.rectangle"
    }
  }
}
