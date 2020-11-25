//
//  FileHandler.swift
//  StoreAway
//
//  Created by JayFi on 14.11.20.
//

import Foundation
import SwiftUI

struct Stats : Hashable {
  var filetypes : [String]
  var numberOfFiles: Int
  var size : UInt64
  var sizeString : String
}

class FileHandler {
  
  let fm = FileManager.default
  
  func action(data : UserData){
    
    
    for folder in data.watchedFolders {
      for map in data.mappingData {
        for n in map.name {
          let files = getFilesInFolder(path: folder, filetype: n)
          for file in files {
            actionFileToFolder(file: file, destination: map.path, copy: data.copyObjects)
          }
        }
      }
    }
  }
  
  func actionFileToFolder(file: URL, destination: URL, copy: Bool){
    
      
      var filename = file.lastPathComponent
      var destination_path = (destination.appendingPathComponent(filename)).path
      
      if fm.fileExists(atPath: destination_path)
      {
        let answer = dialog(question: filename + " exists", text: "Replace File?")
        
        switch answer {
          case .alertFirstButtonReturn:
            try? fm.removeItem(atPath: destination_path)
            
          case .alertSecondButtonReturn:
            var counter = 0
            repeat{
              counter += 1
              let ext = file.pathExtension
              let temp = file.deletingPathExtension().lastPathComponent
              filename = temp + " " + String(counter) + "." + ext
              destination_path = (destination.appendingPathComponent(filename)).path
            }while(fm.fileExists(atPath: destination_path))
            
          case .alertThirdButtonReturn:
            return
            
          default:
            print("default")
        }
        
      }
    do{
      if copy {
        try fm.copyItem(atPath: file.path, toPath: destination_path)
      } else {
        try fm.moveItem(atPath: file.path, toPath: destination_path)
      }
      
    }
    catch{
      print("actionFileToFolder - this did not work")
    }
  }
  
  func getFilesInFolder( path: URL, filetype: String) -> [URL] {
    
    let resourceKeys = Set<URLResourceKey>([.nameKey])
    let enumerator = fm.enumerator(at: path, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)
    let files = (enumerator?.allObjects as! [URL]).filter{$0.pathExtension.contains(filetype.lowercased())}
    
    return files
     
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
  
  func getStats(folders : [URL], mappings: [Mapping]) -> [Stats] {
    
    var stats : [Stats] = []
    var size : UInt64  = 0
    var counter = 0
    
    for map in mappings {
      counter = 0
      size = 0
      for folder in folders{
        for n in map.name {
          let files = getFilesInFolder(path: folder, filetype: n)
          for file in files {
            counter += 1
            let fileAttributes = try? FileManager.default.attributesOfItem(atPath: file.path)
            if let fileSize = fileAttributes![FileAttributeKey.size] {
              size += fileSize as! UInt64
            }
          }
        }
      }

      stats.append(Stats(filetypes: map.name, numberOfFiles: counter, size: size, sizeString: sizeToString(size: size)))
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
