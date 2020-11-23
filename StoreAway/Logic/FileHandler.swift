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
  
  
  func getFilesInFolder( path: URL, filetype: String) -> [URL] {
    let enumerator = fm.enumerator(atPath: path.path)
    let files = (enumerator?.allObjects as! [String]).filter{$0.lowercased().contains(filetype.lowercased())}
    
    var file_url : [URL] = []
    for f in files{
      let path = URL(fileURLWithPath: path.path).appendingPathComponent(f)
      file_url.append(path)
    }
    return file_url
  }
  
  func copy(data : UserData){
    
    for folder in data.watchedFolders {
      for map in data.mappingData {
        for n in map.name {
          let files = getFilesInFolder(path: folder, filetype: n)
          for file in files {
            
            copyFileToFolder(file: file, destination: map.path)
          }
        }
      }
    }
  }
  
  func move(data : UserData){
    for folder in data.watchedFolders {
      for map in data.mappingData {
        for n in map.name {
          let files = getFilesInFolder(path: folder, filetype: n)
          for file in files {
            moveFileToFolder(file: file, destination: map.path)
          }
        }
        
      }
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

  func copyFileToFolder(file: URL, destination: URL){
    do{
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
              print(filename)
            }while(fm.fileExists(atPath: destination_path))
            
          case .alertThirdButtonReturn:
            return
            
          default:
            print("default")
        }
        
      }
      
      try fm.copyItem(atPath: file.path, toPath: destination_path)
    }
    catch{
      print("copy - this did not work")
    }
  }
  
  func moveFileToFolder(file: URL, destination: URL){
    do{
      let filename = file.lastPathComponent
      try fm.moveItem(atPath: file.path, toPath: (destination.appendingPathComponent(filename)).path)
    }
    catch{
      print("move - this did not work")
    }
  }
  
}
