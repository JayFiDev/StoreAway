//
//  MainDetailView.swift
//  StoreAway
//
//  Created by Jürgen Fink on 23.11.20.
//

import SwiftUI

struct MainDetailView: View {

  @EnvironmentObject var userData: DataHandler

  var body: some View {

    VStack(alignment: .trailing) {

      List(userData.statistics, id: \.self) { stat in
        HStack {
          Spacer()
          DetailStatisticView(statistic: stat)
        }
      }

    }.frame(width: 300, height: 300, alignment: .center)
  }
}

struct MainDetailView_Previews: PreviewProvider {
  static var previews: some View {
    MainDetailView().environmentObject(DataHandler())
  }
}
