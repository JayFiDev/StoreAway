//
//  FileHandler.swift
//  StoreAway
//
//  Created by JayFi on 14.11.20.
//

import Foundation
import SwiftUI

class FileHandler {
  
  let fm = FileManager.default
  
  
  func getFilesInFolder( path: URL, filetype: String) -> [File] {
    
    var files : [File] = []
    
    let resourceKeys = Set<URLResourceKey>([.nameKey])
    let enumerator = fm.enumerator(at: path, includingPropertiesForKeys: Array(resourceKeys), options: .skipsHiddenFiles)
    let filtered_list = (enumerator?.allObjects as! [URL]).filter{$0.pathExtension.contains(filetype.lowercased())}
    
    for item in filtered_list {
      
      let filename = item.deletingPathExtension().lastPathComponent
      let filetype = item.pathExtension
      let relativePath = item.relativePath(from: path)
      
      files.append(File(path: item, relativePath: relativePath != nil ? relativePath! : "", filename: filename, filetype: filetype))
      
    }
    
    return files
    
  }
  
  func action(data : UserData){
    
    for folder in data.watchedFolders {
      for map in data.mappingData {
        for n in map.name {
          let files = getFilesInFolder(path: folder, filetype: n)
          for file in files {
            actionFileToFolder(file: file, destination: map.path, copyOrMove: data.copyObjects, keepFolderStructure: data.keepFolderStructure)
          }
        }
      }
    }
  }
  
  func actionFileToFolder(file: File, destination: URL, copyOrMove: Bool, keepFolderStructure: Bool){
    
    var filename = file.path.lastPathComponent
    var destination_path = (destination.appendingPathComponent(filename))
    
    
    if(keepFolderStructure) //keep sub-folder structure
    {
      destination_path = destination.appendingPathComponent(file.relativePath)
      
      let subfolder_path = (destination.appendingPathComponent(file.relativePath)).deletingLastPathComponent()
      if !fm.fileExists(atPath: subfolder_path.path){
        try? FileManager.default.createDirectory(at: subfolder_path, withIntermediateDirectories: true, attributes: nil)
      }
    }
    
    if fm.fileExists(atPath: destination_path.path)
    {
      var answer : NSApplication.ModalResponse = .alertThirdButtonReturn
      
      DispatchQueue.main.sync { //call dialog from main thread -> exception when called from background thread
        answer = dialog(question: filename + " exists at " + (destination_path.deletingLastPathComponent()).path + "/", text: "Replace File?")
      }
      
      switch answer {
        case .alertFirstButtonReturn:
          try? fm.removeItem(atPath: destination_path.path)
          
        case .alertSecondButtonReturn:
          var counter = 0
          repeat{
            counter += 1
            let ext = file.path.pathExtension
            let temp = file.path.deletingPathExtension().lastPathComponent
            filename = temp + " " + String(counter) + "." + ext
            destination_path = (destination.appendingPathComponent(filename))
          }while(fm.fileExists(atPath: destination_path.path))
          
        case .alertThirdButtonReturn:
          return
          
        default:
          return
      }
      
    }
    do{
      if copyOrMove {
        try fm.copyItem(atPath: file.path.path, toPath: destination_path.path)
      } else {
        try fm.moveItem(atPath: file.path.path, toPath: destination_path.path)
      }
      
    }
    catch{
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
extension FileHandler{
  
  func preview(mapping: [Mapping], folders : [URL]) -> [Previews] {
    
    var previews : [Previews] = []
    
    for map in mapping {
      var folderList : [Folder] = []
      
      for folder in folders {
        
        for n in map.name {
          let files = getFilesInFolder(path: folder, filetype: n)
          folderList.append(Folder(path: folder, files: files))
        }
      }
      previews.append(Previews(map: map, folder: folderList))
    }
    return previews
  }
  
}

//statistic functions
extension FileHandler {
  
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
            let fileAttributes = try? FileManager.default.attributesOfItem(atPath: file.path.path)
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
