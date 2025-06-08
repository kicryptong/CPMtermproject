// WeatherLogListView.swift

import SwiftUI

struct WeatherLogListView: View {
    @EnvironmentObject var weatherLogManager: WeatherLogManager
    @State private var showDeleteConfirmation = false
    @State private var logToDelete: WeatherLog? = nil

    var body: some View {
        NavigationView {
            if weatherLogManager.savedLogs.isEmpty {
                VStack {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                        .padding()
                    Text("No weather logs recorded.")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .navigationTitle("Weather Log List")
            } else {
                List {
                    ForEach(weatherLogManager.savedLogs) { log in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(log.formattedTimestamp)
                                    .font(.headline)
                                Spacer()
                                Text(log.location)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            HStack(spacing: 15) {
                                Text("☀️ \(log.temperature)")
                                Text("💧 \(log.description)")
                                Text("💨 \(String(format: "%.1f", log.windSpeed)) m/s")
                            }
                            .font(.caption)
                            
                            if let memo = log.userMemo, !memo.isEmpty {
                                Text("📝 Memo: \(memo)")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .padding(.top, 2)
                            }
                        }
                        .padding(.vertical, 5)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                logToDelete = log
                                showDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .navigationTitle("Weather Log List")
                .toolbar {
                    EditButton()
                }
            }
        }
        .alert("Delete Log", isPresented: $showDeleteConfirmation, presenting: logToDelete) { logToDelete in
            Button("Delete", role: .destructive) {
                if let log = self.logToDelete {
                    weatherLogManager.deleteLog(log: log)
                }
                self.logToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                self.logToDelete = nil
            }
        } message: { logToDelete in
            Text("Are you sure you want to delete the weather log from \(logToDelete.formattedTimestamp)?")
        }
    }
}
