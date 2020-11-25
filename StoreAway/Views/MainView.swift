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
  @State private var hovering = false
  @State private var isRunning = false
  
  var body: some View {
    
    
    VStack{
      
      HStack {
        ZStack{
          Circle()
            .foregroundColor(hovering ? .accentColor : .gray)
            .frame(width: 200, height: 200)
            .alert(isPresented: $showingAlert) {
              Alert(title: Text("Nothing to do"), message: Text("Please add watched folders and mappings in Preferences"), dismissButton: .default(Text("Ok")))
            }
          
          if isRunning{
            ProgressView()
          }else{
            Text("Store away").font(.title)
          }
          
          
        }
        .contentShape(Circle())
        .onHover(perform: { h in
          hovering = h
        })
        .onTapGesture {
          if userData.watchedFolders.count > 0
              && userData.mappingData.count > 0 {
            
            isRunning = true

            DispatchQueue.global().async {
              filehandler.action(data: userData)
              
              
              DispatchQueue.main.async  {
                self.isRunning = false
                self.userData.updateStats()
              }
            }
            
          } else
          {
            self.showingAlert = true
          }
        }
        .padding(.horizontal)
        
        
        if userData.detailViewEnabled{
          
          MainDetailView()
            .padding(.leading)
          
        }
      }
      
      
      
      
    }.frame(width: userData.detailViewEnabled ? 700 : 300, height: 300, alignment: .center)
    
    
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    MainView().environmentObject(UserData())
  }
}
