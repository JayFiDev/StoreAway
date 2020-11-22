//
//  FileHandler.swift
//  StoreAway
//
//  Created by JayFi on 14.11.20.
//

import Foundation

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
  

  
  func copyFileToFolder(file: URL, destination: URL){
    do{
      
      let filename = file.lastPathComponent
      try fm.copyItem(atPath: file.path, toPath: (destination.appendingPathComponent(filename)).path)
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
