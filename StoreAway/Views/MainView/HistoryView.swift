//
//  HistoryView.swift
//  StoreAway
//

import SwiftUI

struct HistoryView: View {

  @EnvironmentObject var userData: DataHandler
  @Environment(\.dismiss) var dismiss

  var body: some View {
    VStack(spacing: 0) {
      // Title bar
      HStack {
        Text("Operation History")
          .font(.title3)
          .fontWeight(.semibold)
        Spacer()
        if !userData.operationHistory.isEmpty {
          Button("Clear All") {
            userData.operationHistory.removeAll()
          }
          .foregroundColor(.red)
          .buttonStyle(.plain)
        }
        Button("Done") { dismiss() }
          .buttonStyle(.borderedProminent)
      }
      .padding([.horizontal, .top], 20)
      .padding(.bottom, 12)

      Divider()

      if userData.operationHistory.isEmpty {
        VStack(spacing: 14) {
          Image(systemName: "clock")
            .font(.system(size: 44, weight: .ultraLight))
            .foregroundColor(.secondary.opacity(0.5))
          Text("No Operations Yet")
            .font(.title3)
            .fontWeight(.medium)
          Text("Organize some files to see your history here.")
            .font(.callout)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else {
        List(userData.operationHistory) { record in
          HistoryRowView(record: record)
        }
        .listStyle(.inset)
      }
    }
    .frame(width: 500, height: 420)
    .background(Color(NSColor.windowBackgroundColor))
  }
}

struct HistoryRowView: View {
  let record: OperationRecord

  private var relativeDate: String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    return formatter.localizedString(for: record.date, relativeTo: Date())
  }

  var body: some View {
    HStack(spacing: 12) {
      ZStack {
        Circle()
          .fill(Color.accentColor.opacity(0.12))
          .frame(width: 36, height: 36)
        Image(systemName: record.sourceSymbol)
          .font(.system(size: 14))
          .foregroundColor(.accentColor)
      }

      VStack(alignment: .leading, spacing: 3) {
        HStack {
          if record.filesMoved > 0 {
            Text("\(record.filesMoved) moved")
              .font(.callout)
              .fontWeight(.medium)
          }
          if record.filesCopied > 0 {
            Text("\(record.filesCopied) copied")
              .font(.callout)
              .fontWeight(.medium)
          }
          if record.totalFiles == 0 {
            Text("No files processed")
              .font(.callout)
              .foregroundColor(.secondary)
          }
        }
        Text("\(record.sourceName) · \(relativeDate)")
          .font(.caption)
          .foregroundColor(.secondary)
      }

      Spacer()

      Text(record.date, style: .time)
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .padding(.vertical, 3)
  }
}

struct HistoryView_Previews: PreviewProvider {
  static var previews: some View {
    HistoryView().environmentObject(DataHandler())
  }
}
