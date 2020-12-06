//
//  MainDetailView.swift
//  StoreAway
//
//  Created by Jürgen Fink on 23.11.20.
//

import SwiftUI

struct MainDetailView: View {
  
  @EnvironmentObject var userData: DataObject
  
  var body: some View {
    
    VStack(alignment: .trailing) {
      
      List(userData.statistics, id: \.self) { s in
        HStack {
          Spacer()
          DetailStatisticView(stats: s)
        }
      }

      
    }.frame(width: 380, height: 300, alignment: .center)
  }
}

struct MainDetailView_Previews: PreviewProvider {
  static var previews: some View {
    MainDetailView().environmentObject(DataObject())
  }
}
