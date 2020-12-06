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
  
  @EnvironmentObject var userData: DataHandler
  @State private var showingAlert = false
  @State private var hovering = false
  @State private var isRunning = false
  
  @State private var hoveringPreview = false
  @State private var showPreview = false
  
  fileprivate func onTappedCircle() {
    if isRunning {
      return
    }
    if userData.watchedFolders.count > 0
        && userData.mappingData.count > 0 {
      
      isRunning = true
      
      DispatchQueue.global().async {
        userData.action()
        
        DispatchQueue.main.async  {
          self.isRunning = false
          self.userData.update()
        }
      }
      
    } else
    {
      self.showingAlert = true
    }
  }
  
  fileprivate func showEmptyMappingAlert() -> Alert {
    return Alert(title: Text("Nothing to do"), message: Text("Please add watched folders and mappings in Preferences"), dismissButton: .default(Text("Ok")))
  }
  
  var body: some View {
    
    
    HStack{
      
      VStack{
        ZStack{
          Circle()
            .foregroundColor(hovering ? .accentColor : .gray)
            .frame(width: 200, height: 200)
          
          if isRunning{
            ProgressView()
              .scaleEffect(1.25, anchor: .center)
          }else{
            Text("Store away").font(.title)
          }
          
        }
        .contentShape(Circle())
        .onHover(perform: { h in
          hovering = h
        })
        .onTapGesture {
          onTappedCircle()
        }
        .padding(.horizontal)
        
        ZStack{
          Circle()
            .foregroundColor(hoveringPreview ? .accentColor : .gray)
            .frame(width: 80, height: 80)
            .sheet(isPresented: $showPreview) {
              PreviewView()
            }
          Text("Preview").font(.title2)
        }
        .contentShape(Circle())
        .onHover(perform: { h in
          hoveringPreview = h
        })
        .onTapGesture {
          showPreview = true
        }
        .padding(.horizontal)
        
      }
      if userData.options.detailViewEnabled{
        
        MainDetailView()
          .padding(.leading)
        
      }
      
    }.frame(width: userData.options.detailViewEnabled ? 600 : 300, height: 350, alignment: .center)
    .alert(isPresented: $showingAlert) {
      showEmptyMappingAlert()
    }
    
    
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    MainView().environmentObject(DataHandler())
  }
}
