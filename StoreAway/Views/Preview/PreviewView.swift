//
//  PreviewView.swift
//  StoreAway
//
//  Created by Jürgen Fink on 25.11.20.
//

import SwiftUI

struct PreviewView: View {

  @EnvironmentObject var userData: DataHandler
  @Environment(\.presentationMode) var presentationMode
  @State private var selectedPreview: Previews?

  var body: some View {

    VStack {
      NavigationView {
        PreviewSidebarView(preview: $selectedPreview)
        PreviewDetailView(preview: $selectedPreview)
      }

      Button(action: {
        self.presentationMode.wrappedValue.dismiss()
      }, label: {
        Text("Close")
      })

    }
    .padding(.all)
    .frame(width: 900, height: 500, alignment: .center)
    .onAppear(perform: {
      userData.update()
      if userData.previews.count > 0 {
        selectedPreview = userData.previews.first
      }
    })
  }
}

struct PreviewView_Previews: PreviewProvider {
  static var previews: some View {
    PreviewView().environmentObject(DataHandler())
  }
}
