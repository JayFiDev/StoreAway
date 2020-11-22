//
//  ContentView.swift
//  StoreAway
//
//  Created by JayFi on 14.11.20.
//

import SwiftUI

struct MainView: View {
  
  let filehandler = FileHandler()
  let input = InputHandler()
  @EnvironmentObject var userData: UserData
  @State private var showingAlert = false
  
  var body: some View {
    
    VStack{
     
      ZStack{
        Circle()
          .onTapGesture {
            
            if userData.watchedFolders.count > 0
                && userData.mappingData.count > 0 {
              filehandler.copy(data: userData)
            } else
            {
              self.showingAlert = true
            }
            
            
            
            
          }
          .foregroundColor(.accentColor)
          .frame(width: 200, height: 200)
          .alert(isPresented: $showingAlert) {
                      Alert(title: Text("Nothing to do"), message: Text("Please add watched folders and mappings in Preferences"), dismissButton: .default(Text("Ok")))
                  }
        
          Text("Store away").font(.title)
      }
        
    }.frame(width: 300, height: 300, alignment: .center)
    
    
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    MainView().environmentObject(UserData())
  }
}
