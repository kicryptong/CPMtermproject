//
//  WeatherLogListView.swift
//  NewWeather
//
//  Created by 성준영 on 5/28/25.
//



import SwiftUI

struct WeatherLogListView: View {
    @EnvironmentObject var weatherLogManager: WeatherLogManager
    @State private var showDeleteConfirmation = false
    @State private var logToDelete: WeatherLog? = nil

    var body: some View {
        NavigationView { // 각 탭 또는 시트 내에서 독립적인 NavigationView를 가질 수 있음
            if weatherLogManager.savedLogs.isEmpty {
                VStack {
                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                        .padding()
                    Text("기록된 날씨 정보가 없습니다.")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .navigationTitle("날씨 기록 목록")
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
                                Text("☀️ \(log.temperature)") // 아이콘은 mainWeather 기반으로 변경 가능
                                Text("💧 \(log.description)")
                                Text("💨 \(String(format: "%.1f", log.windSpeed)) m/s")
                            }
                            .font(.caption)
                            
                            if let memo = log.userMemo, !memo.isEmpty {
                                Text("📝 메모: \(memo)")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                    .padding(.top, 2)
                            }
                        }
                        .padding(.vertical, 5)
                        .swipeActions(edge: .trailing) { // 스와이프 삭제
                            Button(role: .destructive) {
                                logToDelete = log
                                showDeleteConfirmation = true
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                    }
                    // .onDelete(perform: weatherLogManager.deleteLog) // 이 방식은 ID 기반 삭제가 더 안전
                }
                .navigationTitle("날씨 기록 목록")
                .toolbar {
                    EditButton() // iOS 기본 편집 모드 (순서 변경 등은 미구현)
                }
            }
        }
        .alert("기록 삭제", isPresented: $showDeleteConfirmation, presenting: logToDelete) { logToDelete in
            Button("삭제", role: .destructive) {
                if let log = self.logToDelete {
                    weatherLogManager.deleteLog(log: log)
                }
                self.logToDelete = nil
            }
            Button("취소", role: .cancel) {
                self.logToDelete = nil
            }
        } message: { logToDelete in
            Text("\(logToDelete.formattedTimestamp)의 날씨 기록을 삭제하시겠습니까?")
        }
    }
}

struct WeatherLogListView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherLogListView()
            .environmentObject(WeatherLogManager()) // Preview를 위해 임시 Manager 주입
    }
}
