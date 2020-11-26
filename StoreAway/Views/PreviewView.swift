//
//  PreviewView.swift
//  StoreAway
//
//  Created by Jürgen Fink on 25.11.20.
//

import SwiftUI



struct PreviewView: View {
  
  @EnvironmentObject var userData: UserData
  @Environment(\.presentationMode) var presentationMode
  @State private var selectedPreview: Previews?
  
  var body: some View {
    
    VStack {
      NavigationView(){
        SidebarView(preview: $selectedPreview)
        DetailView(preview: $selectedPreview)
        
      }
      
      Button(action: {
        
        self.presentationMode.wrappedValue.dismiss()
        
      }, label: {
        Text("Close")
      })
      
    }.padding(.all)
    .frame(width: 750, height: 500, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
    .onAppear(perform: {
      //selectedMapping = userData.mappingData.first
      userData.updatePreviews()
    })
    
    
  }
}

struct SidebarView: View {
  
    @EnvironmentObject var userData: UserData
    let filehandler = FileHandler()
    @Binding var preview: Previews?
  
    var body: some View {
      List(userData.previews, id: \.self, selection: $preview) { preview in
        Text("\(preview.map.name.joined(separator: ", "))")
        }
       .listStyle(SidebarListStyle())
        .frame(minWidth: 180, idealWidth: 200, maxWidth: 300)
    }
}

struct DetailView: View {
    @EnvironmentObject var userData: UserData
    let filehandler = FileHandler()
  
    @Binding var preview: Previews?
  
    var body: some View {
      
      
      VStack{
        if preview != nil {
          List(preview?.pathlist ?? [], id: \.self) { p in
            Text("\(p.oldPath.path)")
            Text("\(p.newPath.path)")
            }
        } else{
          Text("No mapping selected")
        }
        
      }
      
    }
}


struct PreviewView_Previews: PreviewProvider {
  static var previews: some View {
    PreviewView()
  }
}
