//
//  AddMapping.swift
//  StoreAway
//
//  Created by JayFi on 18.11.20.
//

import SwiftUI

struct AddMappingView: View {
  
  let input = InputHandler()
  
  @Environment(\.presentationMode) var mode
  @EnvironmentObject var userData: UserData
  @State private var filetype: String = "type1, type2"
  @State private var path: URL = URL(fileURLWithPath: "Select Path")
  @State private var path_selected : Bool = false
  
  
  var body: some View {
    VStack(alignment: .leading) {
      
      Label(
        title: { Text("Filetype(s) - seperate by , ") },
        icon: { Image(systemName: "doc.text.magnifyingglass") }
      )
      .padding([.leading, .top])
      TextField("Filetype", text: $filetype).frame(width: 130, height: 20, alignment: .leading).padding(.leading)
      
      Label(
        title: { Text("Destinationn") },
        icon: { Image(systemName: "tray") }
      )
      .padding([.leading, .top])
      
      HStack {
        if !path_selected {
          Button(action: {
            let selectedFolder = input.showInputSelectDialog()
            if (selectedFolder != nil) {
              path = selectedFolder!
              path_selected = true
            }
            
          }, label: {
            Text("Select destination")
          }).padding(.leading)
          
        }
        else {
          Text(path.path)
            .padding([.top, .leading], 1.0)
            .frame(width: 130, height: 40)
        }
        
        
      }
      Spacer()
      
      HStack{
        Button(action: {
          
          let temp = filetype.replacingOccurrences(of: " ", with: "")
          let filetypes : [String] = temp.components(separatedBy: ",")
          
          userData.addMapping(name: filetypes, path: path)
          self.mode.wrappedValue.dismiss()
          
        }, label: {
          Text("Add mapping")
        }).disabled(!path_selected)
        
        Button(action: {
          self.mode.wrappedValue.dismiss()
        }, label: {
          Text("Cancel")
        })
        
      }.padding([.leading, .bottom])
      
      
    }.frame(width: 250, height: 200, alignment: .leading)
  }
}

struct AddMapping_Previews: PreviewProvider {
  static var previews: some View {
    AddMappingView()
  }
}
