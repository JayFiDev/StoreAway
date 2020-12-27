//
//  InputHandler.swift
//  StoreAway
//
//  Created by JayFi on 14.11.20.
//

import Foundation
import SwiftUI

class InputHandler {

  func showInputSelectDialog() -> URL? {

    let dialog = NSOpenPanel()

    dialog.title                   = "Choose a folder"
    dialog.showsResizeIndicator    = true
    dialog.showsHiddenFiles        = false
    dialog.allowsMultipleSelection = false
    dialog.canChooseFiles          = false
    dialog.canChooseDirectories    = true

    if dialog.runModal() ==  NSApplication.ModalResponse.OK {
        let result = dialog.url // Pathname of the file

        if result != nil {
          return result!
        }

    }
    return nil
  }

}
