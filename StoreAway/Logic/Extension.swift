//
//  URLextension.swift
//  StoreAway
//
//  Created by Jürgen Fink on 04.12.20.
//

import Foundation

//relative path
extension URL{
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

      var i = 0
      while i < destComponents.count &&
            i < baseComponents.count &&
            destComponents[i] == baseComponents[i] {
              i += 1
      }

      var relComponents = Array(repeating: "..", count: baseComponents.count - i)
      relComponents.append(contentsOf: destComponents[i...])
      return relComponents.joined(separator: "/")
  }
}
