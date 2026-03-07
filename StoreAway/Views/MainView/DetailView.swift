//
//  DetailView.swift
//  StoreAway
//

import SwiftUI

struct DetailView: View {

  @EnvironmentObject var userData: DataHandler
  @Binding var selection: SidebarSelection?

  var body: some View {
    Group {
      if let selection = selection {
        switch selection {
        case .mapping(let mapping):
          MappingDetailView(mapping: mapping)
        case .folder(let folder):
          FolderDetailView(folder: folder)
        }
      } else {
        emptyState
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  // MARK: - Empty State

  private var emptyState: some View {
    VStack(spacing: 16) {
      Image(systemName: "archivebox")
        .font(.system(size: 56, weight: .ultraLight))
        .foregroundColor(.secondary.opacity(0.6))
      VStack(spacing: 6) {
        Text("Select a Mapping or Folder")
          .font(.title3)
          .fontWeight(.medium)
        Text("Choose an item from the sidebar to see which files will be organized.")
          .font(.callout)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .frame(maxWidth: 320)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(NSColor.windowBackgroundColor))
  }
}

// MARK: - Mapping Detail

struct MappingDetailView: View {

  @EnvironmentObject var userData: DataHandler
  let mapping: Mapping

  private var preview: Previews? {
    userData.previews.first { p in
      p.map.id == mapping.id
    }
  }

  private var stats: Stats? {
    userData.statistics.first { stat in
      if mapping.isCustom && stat.isCustom {
        return stat.fileExtensions == mapping.fileExtensions
      } else if !mapping.isCustom && !stat.isCustom {
        return stat.fileType == mapping.fileType
      }
      return false
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // Header
      HStack(spacing: 14) {
        ZStack {
          RoundedRectangle(cornerRadius: 12)
            .fill(Color.accentColor.opacity(0.15))
            .frame(width: 52, height: 52)
          if mapping.isCustom {
            Text(mapping.fileExtensions?.first?.uppercased() ?? "?")
              .font(.system(size: 13, weight: .bold))
              .foregroundColor(.accentColor)
          } else {
            Image(systemName: mapping.fileType?.symbol ?? "doc")
              .font(.system(size: 24, weight: .medium))
              .foregroundColor(.accentColor)
          }
        }

        VStack(alignment: .leading, spacing: 4) {
          if mapping.isCustom {
            Text(mapping.fileExtensions?.joined(separator: ", ") ?? "Custom Extensions")
              .font(.title3)
              .fontWeight(.semibold)
          } else {
            Text(mapping.fileType?.displayString ?? "Unknown")
              .font(.title3)
              .fontWeight(.semibold)
            Text(mapping.fileType?.longDescription ?? "")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }

        Spacer()

        // Stats badges
        if let stats = stats {
          HStack(spacing: 12) {
            StatBadge(value: "\(stats.numberOfFiles)", label: "files")
            StatBadge(value: stats.sizeString, label: "total")
          }
        }
      }
      .padding([.horizontal, .top], 20)
      .padding(.bottom, 12)

      Divider()

      // Destination
      HStack {
        Image(systemName: "arrow.right.circle.fill")
          .foregroundColor(.secondary)
        Text("Destination")
          .font(.caption)
          .foregroundColor(.secondary)
        Text(mapping.path.path)
          .font(.caption)
          .foregroundColor(.primary)
          .lineLimit(1)
          .truncationMode(.middle)
        Spacer()
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 8)

      Divider()

      // File list
      if let preview = preview {
        let allFiles = preview.folder.flatMap { $0.files }
        if allFiles.isEmpty {
          VStack(spacing: 10) {
            Image(systemName: "checkmark.circle")
              .font(.system(size: 36))
              .foregroundColor(.green.opacity(0.7))
            Text("No files to organize")
              .font(.callout)
              .foregroundColor(.secondary)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          List {
            ForEach(preview.folder.filter { !$0.files.isEmpty }, id: \.self) { folder in
              Section(header: Text(folder.path.path).font(.caption)) {
                ForEach(folder.files, id: \.self) { file in
                  HStack {
                    Image(systemName: iconForExtension(file.filetype))
                      .foregroundColor(.secondary)
                      .frame(width: 20)
                    Text(file.filename + (file.filetype.isEmpty ? "" : "." + file.filetype))
                      .font(.body)
                    Spacer()
                    if !file.relativePath.isEmpty {
                      Text(file.relativePath)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    }
                  }
                }
              }
            }
          }
          .listStyle(.inset)
        }
      } else {
        Text("No preview available")
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
    .background(Color(NSColor.windowBackgroundColor))
  }

  private func iconForExtension(_ ext: String) -> String {
    switch ext.lowercased() {
    case "jpg", "jpeg", "png", "gif", "bmp", "heic", "tiff": return "photo"
    case "mp4", "mov", "avi", "mkv", "m4v": return "film"
    case "mp3", "wav", "aac", "flac", "m4a": return "music.note"
    case "pdf": return "doc.richtext"
    case "swift", "c", "cpp", "h", "py", "js", "ts": return "chevron.left.forwardslash.chevron.right"
    case "txt", "rtf", "md": return "doc.text"
    case "zip", "gz", "tar", "rar": return "archivebox"
    default: return "doc"
    }
  }
}

// MARK: - Folder Detail

struct FolderDetailView: View {

  @EnvironmentObject var userData: DataHandler
  let folder: URL

  private var allFiles: [File] {
    userData.previews.flatMap { preview in
      preview.folder
        .filter { $0.path == folder }
        .flatMap { $0.files }
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // Header
      HStack(spacing: 14) {
        Image(systemName: "folder.fill")
          .font(.system(size: 32))
          .foregroundColor(.secondary)
          .frame(width: 52, height: 52)

        VStack(alignment: .leading, spacing: 4) {
          Text(folder.lastPathComponent)
            .font(.title3)
            .fontWeight(.semibold)
          Text(folder.path)
            .font(.caption)
            .foregroundColor(.secondary)
            .lineLimit(1)
            .truncationMode(.middle)
        }

        Spacer()

        StatBadge(value: "\(allFiles.count)", label: "files")
      }
      .padding([.horizontal, .top], 20)
      .padding(.bottom, 12)

      Divider()

      if allFiles.isEmpty {
        VStack(spacing: 10) {
          Image(systemName: "checkmark.circle")
            .font(.system(size: 36))
            .foregroundColor(.green.opacity(0.7))
          Text("No files to organize in this folder")
            .font(.callout)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        List(allFiles, id: \.self) { file in
          HStack {
            Image(systemName: "doc")
              .foregroundColor(.secondary)
              .frame(width: 20)
            Text(file.filename + (file.filetype.isEmpty ? "" : "." + file.filetype))
          }
        }
        .listStyle(.inset)
      }
    }
    .background(Color(NSColor.windowBackgroundColor))
  }
}

// MARK: - Stat Badge

struct StatBadge: View {
  let value: String
  let label: String

  var body: some View {
    VStack(spacing: 2) {
      Text(value)
        .font(.title3)
        .fontWeight(.semibold)
        .monospacedDigit()
      Text(label)
        .font(.caption2)
        .foregroundColor(.secondary)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(Color(NSColor.controlBackgroundColor))
    .cornerRadius(8)
  }
}

struct DetailView_Previews: PreviewProvider {
  static var previews: some View {
    DetailView(selection: .constant(nil))
      .environmentObject(DataHandler())
  }
}
