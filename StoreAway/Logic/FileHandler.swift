//
//  FileHandler.swift
//  StoreAway
//
//  Created by JayFi on 14.11.20.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

class FileHandler {

  let filemanager = FileManager.default
  var alwaysUseOption: NSApplication.ModalResponse = .alertThirdButtonReturn
  var dialogAnswered: Bool = false

  private var currentFileName: String = ""
  private var currentDestinationPath: URL = URL(fileURLWithPath: "")

  private func checkTyping(types: [UTType], supertype: UTType) -> Bool {
    return types.contains(where: { $0.conforms(to: supertype)})
  }

  func getFilesInFolderByUTType(path: URL, filetype: UTType) -> [File] {

    var files: [File] = []
    let resourceKeys: [URLResourceKey] = [.nameKey, .typeIdentifierKey]
    let enumerator = filemanager.enumerator(at: path, includingPropertiesForKeys: resourceKeys,
                                            options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                              print("directoryEnumerator error at \(url): ", error)
                                              return true

                                            })!

    for case let item as URL in enumerator {

      //only get public filetypes for now
      let types = UTType.types(tag: item.pathExtension, tagClass: .filenameExtension, conformingTo: nil).filter { type in
        return type.isPublic
      }

      if checkTyping(types: types, supertype: filetype) {
        let filename = item.deletingPathExtension().lastPathComponent
        let fileExtension = item.pathExtension
        let relativePath = item.relativePath(from: path)

        files.append(File(path: item, relativePath: relativePath != nil ? relativePath! : "", filename: filename, filetype: fileExtension))
      }

    }

    return files
  }

  func getFilesInFolder(path: URL, filetypes: [String]) -> [File] {

    var files: [File] = []
    let resourceKeys: [URLResourceKey] = [.nameKey, .typeIdentifierKey]
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

        var files: [File] = []
        if map.isCustom {
          files = getFilesInFolder(path: folder, filetypes: map.fileExtensions!)
        } else {
          files = getFilesInFolderByUTType(path: folder, filetype: map.fileType!.type)
        }

        for file in files {
          actionFileToFolder(file: file, destination: map.path, options: options)
        }
      }
    }
    dialogAnswered = false
  }

  private func actionFileToFolder(file: File, destination: URL, options: Options) {

    currentFileName = file.path.lastPathComponent
    currentDestinationPath = (destination.appendingPathComponent(currentFileName))

    if(options.keepFolderStructure) //keep sub-folder structure
    {
      createFolderStructure(destination, file)
    }

    if filemanager.fileExists(atPath: currentDestinationPath.path) {

      let answer = getUserResponse(options)

      switch options.askEveryFile ? answer : alwaysUseOption {

      case .alertFirstButtonReturn:
        try? filemanager.removeItem(atPath: currentDestinationPath.path)

      case .alertSecondButtonReturn:
        var counter = 0
        repeat {
          counter += 1
          let ext = file.path.pathExtension
          let temp = file.path.deletingPathExtension().lastPathComponent
          currentFileName = temp + " " + String(counter) + "." + ext
          currentDestinationPath = currentDestinationPath.deletingLastPathComponent()
                                      .appendingPathComponent(currentFileName)
        }while(filemanager.fileExists(atPath: currentDestinationPath.path))

      case .alertThirdButtonReturn:
        return

      default:
        return
      }

    }

    do {
      if options.copyObjects {
        try filemanager.copyItem(atPath: file.path.path, toPath: currentDestinationPath.path)
      } else {
        try filemanager.moveItem(atPath: file.path.path, toPath: currentDestinationPath.path)
      }

    } catch {
      print("actionFileToFolder - this did not work")
    }
  }

  private func createFolderStructure(_ destination: URL, _ file: File) {
    currentDestinationPath = destination.appendingPathComponent(file.relativePath)

    let subfolderPath = (destination.appendingPathComponent(file.relativePath)).deletingLastPathComponent()
    if !filemanager.fileExists(atPath: subfolderPath.path) {
      try? FileManager.default.createDirectory(at: subfolderPath, withIntermediateDirectories: true, attributes: nil)
    }
  }

  private func getUserResponse(_ options: Options) -> NSApplication.ModalResponse {
    var answer: NSApplication.ModalResponse = .alertThirdButtonReturn

    let question: String = options.askEveryFile
                                    ? currentFileName + " exists at "
                                        + (currentDestinationPath.deletingLastPathComponent()).path + "/"
                                    : "File(s) exist at " + (currentDestinationPath.deletingLastPathComponent()).path + "/"

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

    return answer
  }

  private func dialog(question: String, text: String) -> NSApplication.ModalResponse {
    let alert = NSAlert()
    alert.messageText = question
    alert.informativeText = text
    alert.alertStyle = .critical
    alert.addButton(withTitle: "Overwrite")
    alert.addButton(withTitle: "Rename & copy")
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
        var files: [File] = []
        if map.isCustom {
          files = getFilesInFolder(path: folder, filetypes: map.fileExtensions!)
        } else {
          files = getFilesInFolderByUTType(path: folder, filetype: map.fileType!.type)
        }

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

        var files: [File] = []
        if map.isCustom {
          files = getFilesInFolder(path: folder, filetypes: map.fileExtensions!)
        } else {
          files = getFilesInFolderByUTType(path: folder, filetype: map.fileType!.type)
        }

        for file in files {
          counter += 1
          let fileAttributes = try? FileManager.default.attributesOfItem(atPath: file.path.path)
          if let fileSize = fileAttributes![FileAttributeKey.size]  as? UInt64 {
            size += fileSize
          }
        }
      }

      if map.isCustom {
        stats.append(Stats(fileExtensions: map.fileExtensions!, isCustom: true, numberOfFiles: counter, size: size, sizeString: sizeToString(size: size)))
      } else {
        stats.append(Stats(fileType: map.fileType!, isCustom: false, numberOfFiles: counter, size: size, sizeString: sizeToString(size: size)))
      }
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
