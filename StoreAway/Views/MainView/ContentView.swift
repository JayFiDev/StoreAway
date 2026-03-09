//
//  ContentView.swift
//  StoreAway
//

import SwiftUI

enum SidebarSelection: Hashable {
  case mapping(Mapping)
  case folder(URL)
}

struct ContentView: View {

  @EnvironmentObject var userData: DataHandler
  @State private var selection: SidebarSelection?
  @State private var showPreview = false
  @State private var showHistory = false
  @State private var showEmptyAlert = false

  var body: some View {
    NavigationSplitView {
      SidebarView(selection: $selection)
        .navigationSplitViewColumnWidth(min: 200, ideal: 230, max: 300)
    } detail: {
      DetailView(selection: $selection)
    }
    .toolbar {
      ToolbarItemGroup(placement: .primaryAction) {
        if userData.isRunning {
          ProgressView()
            .scaleEffect(0.75)
            .frame(width: 20, height: 20)
        } else {
          Button {
            if userData.watchedFolders.isEmpty || userData.mappingData.isEmpty {
              showEmptyAlert = true
            } else {
              userData.runAction(triggerSource: .manual)
            }
          } label: {
            Label("Store Away", systemImage: "archivebox.fill")
          }
          .help("Organize files in watched folders now (⌘↩)")
          .keyboardShortcut(.return, modifiers: .command)
        }

        Button { showPreview = true } label: {
          Label("Preview", systemImage: "eye")
        }
        .help("Preview what will be organized")

        Button { showHistory = true } label: {
          Label("History", systemImage: "clock.arrow.circlepath")
        }
        .help("View operation history")
      }
    }
    .frame(minWidth: 680, minHeight: 420)
    .sheet(isPresented: $showPreview) {
      PreviewView()
        .environmentObject(userData)
    }
    .sheet(isPresented: $showHistory) {
      HistoryView()
        .environmentObject(userData)
    }
    .alert("Nothing to do", isPresented: $showEmptyAlert) {
      Button("OK") {}
    } message: {
      Text("Please add watched folders and mappings in Preferences.")
    }
    .onReceive(NotificationCenter.default.publisher(for: .showPreviewNotification)) { _ in
      showPreview = true
    }
    .onDrop(of: ["public.file-url"], isTargeted: nil) { providers in
      return userData.dropHandler(providers)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView().environmentObject(DataHandler())
  }
}
