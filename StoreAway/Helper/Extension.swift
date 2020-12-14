//
//  URLextension.swift
//  StoreAway
//
//  Created by Jürgen Fink on 04.12.20.
//

import Foundation

//relative path
extension URL {
  func relativePath(from base: URL) -> String? {
      // Ensure that both URLs represent files:
      guard self .isFileURL && base.isFileURL else {
          return nil
      }

      var workBase = base
      if workBase.pathExtension != "" {
          workBase = workBase.deletingLastPathComponent()
      }

      let destComponents = self.standardized.resolvingSymlinksInPath().pathComponents
      let baseComponents = workBase.standardized.resolvingSymlinksInPath().pathComponents

      var inc = 0
      while inc < destComponents.count && inc < baseComponents.count && destComponents[inc] == baseComponents[inc] {
        inc += 1
      }

      var relComponents = Array(repeating: "..", count: baseComponents.count - inc)
      relComponents.append(contentsOf: destComponents[inc...])
      return relComponents.joined(separator: "/")
  }
}
