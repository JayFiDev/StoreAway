//
//  SidebarView.swift
//  StoreAway
//

import SwiftUI

struct SidebarView: View {

  @EnvironmentObject var userData: DataHandler
  @Binding var selection: SidebarSelection?
  @State private var showAddMapping = false
  @State private var editingMapping: Mapping?

  let input = InputHandler()

  var body: some View {
    List(selection: $selection) {
      Section {
        ForEach(userData.mappingData) { mapping in
          MappingRowView(mapping: mapping, stats: statsFor(mapping))
            .tag(SidebarSelection.mapping(mapping))
            .contextMenu {
              Button("Edit Mapping") { editingMapping = mapping }
              Divider()
              Button("Delete", role: .destructive) {
                userData.removeMapping(id: mapping.id)
                if case .mapping(let sel) = selection, sel.id == mapping.id {
                  selection = nil
                }
              }
            }
        }
        .onDelete { indices in
          indices.forEach { userData.removeMapping(index: $0) }
        }
      } header: {
        HStack {
          Text("Mappings")
          Spacer()
          Button {
            showAddMapping = true
          } label: {
            Image(systemName: "plus.circle")
          }
          .buttonStyle(.plain)
          .foregroundColor(.accentColor)
          .help("Add new mapping")
        }
      }

      Section {
        ForEach(userData.watchedFolders, id: \.self) { folder in
          FolderRowView(folder: folder)
            .tag(SidebarSelection.folder(folder))
            .contextMenu {
              Button("Remove Folder", role: .destructive) {
                if let index = userData.watchedFolders.firstIndex(of: folder) {
                  userData.removeFolderWatch(index: index)
                  if case .folder(let sel) = selection, sel == folder {
                    selection = nil
                  }
                }
              }
            }
        }
      } header: {
        HStack {
          Text("Watched Folders")
          Spacer()
          Button {
            if let folder = input.showInputSelectDialog() {
              if !userData.watchedFolders.contains(folder) {
                userData.addFolderWatch(path: folder)
              }
            }
          } label: {
            Image(systemName: "plus.circle")
          }
          .buttonStyle(.plain)
          .foregroundColor(.accentColor)
          .help("Add watched folder")
        }
      }
    }
    .listStyle(.sidebar)
    .sheet(isPresented: $showAddMapping) {
      AddChangeMappingView(
        mapping: Mapping(path: URL(fileURLWithPath: ""), fileExtensions: ["type"]),
        addNew: true
      )
      .environmentObject(userData)
    }
    .sheet(item: $editingMapping) { mapping in
      AddChangeMappingView(mapping: mapping, addNew: false)
        .environmentObject(userData)
    }
  }

  private func statsFor(_ mapping: Mapping) -> Stats? {
    userData.statistics.first { stat in
      if mapping.isCustom && stat.isCustom {
        return stat.fileExtensions == mapping.fileExtensions
      } else if !mapping.isCustom && !stat.isCustom {
        return stat.fileType == mapping.fileType
      }
      return false
    }
  }
}

// MARK: - Row Views

struct MappingRowView: View {
  let mapping: Mapping
  let stats: Stats?

  var body: some View {
    HStack(spacing: 10) {
      ZStack {
        RoundedRectangle(cornerRadius: 8)
          .fill(Color.accentColor.opacity(0.15))
          .frame(width: 36, height: 36)
        if mapping.isCustom {
          Text(mapping.fileExtensions?.first?.uppercased() ?? "?")
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.accentColor)
        } else {
          Image(systemName: mapping.fileType?.symbol ?? "doc")
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.accentColor)
        }
      }

      VStack(alignment: .leading, spacing: 2) {
        if mapping.isCustom {
          Text(mapping.fileExtensions?.joined(separator: ", ") ?? "Custom")
            .font(.body)
            .lineLimit(1)
        } else {
          Text(mapping.fileType?.displayString ?? "Unknown")
            .font(.body)
        }
        Text(mapping.path.lastPathComponent)
          .font(.caption)
          .foregroundColor(.secondary)
          .lineLimit(1)
      }

      Spacer()

      if let stats = stats, stats.numberOfFiles > 0 {
        Text("\(stats.numberOfFiles)")
          .font(.caption2)
          .fontWeight(.semibold)
          .padding(.horizontal, 6)
          .padding(.vertical, 2)
          .background(Color.accentColor)
          .foregroundColor(.white)
          .clipShape(Capsule())
      }
    }
    .padding(.vertical, 2)
  }
}

struct FolderRowView: View {
  let folder: URL

  var body: some View {
    HStack(spacing: 10) {
      Image(systemName: "folder.fill")
        .font(.system(size: 18))
        .foregroundColor(.secondary)
        .frame(width: 36)
      VStack(alignment: .leading, spacing: 2) {
        Text(folder.lastPathComponent)
          .font(.body)
          .lineLimit(1)
        Text(folder.path)
          .font(.caption)
          .foregroundColor(.secondary)
          .lineLimit(1)
      }
    }
    .padding(.vertical, 2)
  }
}

struct SidebarView_Previews: PreviewProvider {
  static var previews: some View {
    SidebarView(selection: .constant(nil))
      .environmentObject(DataHandler())
  }
}
