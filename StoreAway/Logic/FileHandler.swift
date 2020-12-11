//
//  FileHandler.swift
//  StoreAway
//
//  Created by JayFi on 14.11.20.
//

import Foundation
import SwiftUI

class FileHandler {

  let filemanager = FileManager.default
  var alwaysUseOption: NSApplication.ModalResponse = .alertThirdButtonReturn
  var dialogAnswered: Bool = false

  func getFilesInFolder(path: URL, filetypes: [String]) -> [File] {
    var files: [File] = []

    let resourceKeys: [URLResourceKey] = [.nameKey]
    let enumerator = filemanager.enumerator(at: path, includingPropertiesForKeys: resourceKeys,
                                            options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                print("directoryEnumerator error at \(url): ", error)
                                              return true
                                            })!

    for case let item as URL in enumerator {
      if filetypes.contains(item.pathExtension.lowercased()) {
        let filename = item.deletingPathExtension().lastPathComponent
        let filetype = item.pathExtension
        let relativePath = item.relativePath(from: path)

        files.append(File(path: item, relativePath: relativePath != nil ? relativePath! : "", filename: filename, filetype: filetype))
      }
    }

    return files
  }

  func action(mapping: [Mapping], folders: [URL], options: Options) {

    for folder in folders {
      for map in mapping {
        let files = getFilesInFolder(path: folder, filetypes: map.filetypes)
        for file in files {
          actionFileToFolder(file: file, destination: map.path, options: options)
        }
      }
    }
    dialogAnswered = false
  }

  fileprivate func keepFolderStructure(_ options: Options, _ destinationPath: inout URL, _ destination: URL, _ file: File) {
    if(options.keepFolderStructure) //keep sub-folder structure
    {
      destinationPath = destination.appendingPathComponent(file.relativePath)

      let subfolderPath = (destination.appendingPathComponent(file.relativePath)).deletingLastPathComponent()
      if !filemanager.fileExists(atPath: subfolderPath.path) {
        try? FileManager.default.createDirectory(at: subfolderPath, withIntermediateDirectories: true, attributes: nil)
      }
    }
  }

  func actionFileToFolder(file: File, destination: URL, options: Options) {

    var filename = file.path.lastPathComponent
    var destinationPath = (destination.appendingPathComponent(filename))

    keepFolderStructure(options, &destinationPath, destination, file)

    if filemanager.fileExists(atPath: destinationPath.path) {
      var answer: NSApplication.ModalResponse = .alertThirdButtonReturn

      let question: String = options.askEveryFile
                                      ? filename + " exists at " + (destinationPath.deletingLastPathComponent()).path + "/"
                                      : "File(s) exist at " + (destinationPath.deletingLastPathComponent()).path + "/"

      let text: String = options.askEveryFile ? "Replace file?" : "Replace all files?"

      if !dialogAnswered {
        DispatchQueue.main.sync { //call dialog from main thread -> exception when called from background thread
          answer = dialog(question: question, text: text)
        }
        if !options.askEveryFile {
          dialogAnswered = true
          alwaysUseOption = answer
        }
      }

      switch options.askEveryFile ? answer : alwaysUseOption {
      case .alertFirstButtonReturn:
        try? filemanager.removeItem(atPath: destinationPath.path)

      case .alertSecondButtonReturn:
        var counter = 0
        repeat {
          counter += 1
          let ext = file.path.pathExtension
          let temp = file.path.deletingPathExtension().lastPathComponent
          filename = temp + " " + String(counter) + "." + ext
          destinationPath = destinationPath.deletingLastPathComponent().appendingPathComponent(filename)
        }while(filemanager.fileExists(atPath: destinationPath.path))

      case .alertThirdButtonReturn:
        return

      default:
        return
      }

    }
    do {
      if options.copyObjects {
        try filemanager.copyItem(atPath: file.path.path, toPath: destinationPath.path)
      } else {
        try filemanager.moveItem(atPath: file.path.path, toPath: destinationPath.path)
      }

    } catch {
      print("actionFileToFolder - this did not work")
    }
  }

  func dialog(question: String, text: String) -> NSApplication.ModalResponse {
    let alert = NSAlert()
    alert.messageText = question
    alert.informativeText = text
    alert.alertStyle = .critical
    alert.addButton(withTitle: "Overwrite")
    alert.addButton(withTitle: "Rename & Copy")
    alert.addButton(withTitle: "Ignore file")
    return alert.runModal()
  }

}

//preview functions
extension FileHandler {

  func preview(mapping: [Mapping], folders: [URL]) -> [Previews] {

    var previews: [Previews] = []

    for map in mapping {
      var folderList: [Folder] = []

      for folder in folders {
        let files = getFilesInFolder(path: folder, filetypes: map.filetypes)
        folderList.append(Folder(path: folder, files: files))
      }
      previews.append(Previews(map: map, folder: folderList))
    }
    return previews
  }

}

//statistic functions
extension FileHandler {

  func getStats(folders: [URL], mappings: [Mapping]) -> [Stats] {

    var stats: [Stats] = []
    var size: UInt64  = 0
    var counter = 0

    for map in mappings {
      counter = 0
      size = 0
      for folder in folders {
        let files = getFilesInFolder(path: folder, filetypes: map.filetypes)
        for file in files {
          counter += 1
          let fileAttributes = try? FileManager.default.attributesOfItem(atPath: file.path.path)
          if let fileSize = fileAttributes![FileAttributeKey.size]  as? UInt64 {
            size += fileSize
          }
        }
      }

      stats.append(Stats(filetypes: map.filetypes, numberOfFiles: counter, size: size, sizeString: sizeToString(size: size)))
    }

    return stats

  }

  func sizeToString(size: UInt64) -> String {
    var value: Double = Double(size)
    var factor = 0
    let tokens = ["bytes", "KB", "MB", "GB", "TB"]
    while value > 1024 {
      value /= 1024
      factor += 1
    }
    return String(format: "%4.1f %@", value, tokens[factor])
  }

}

extension FileHandler {

  //https://developer.apple.com/library/archive/documentation/
  //Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html#//apple_ref/doc/uid/TP40009259-SW1
  func getUTI(path: URL) {

  }

}
