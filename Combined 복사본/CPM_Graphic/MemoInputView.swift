//
//  MemoInputView.swift
//  NewWeather
//
//  Created by [Your Name] on 2025/05/28. // 실제 사용자 이름과 날짜로 변경하세요.
//

import SwiftUI

struct MemoInputView: View {
    @EnvironmentObject var weatherLogManager: WeatherLogManager
    @Environment(\.dismiss) var dismiss

    let weather: Weather
    
    // @State private var memoText: String = "" // 메모 입력란이 없으므로 주석 처리 또는 삭제

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 15) {
                Text("현재 날씨 정보 기록")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)

                VStack(alignment: .leading, spacing: 5) {
                    Text("위치: \(weather.location)")
                    Text("온도: \(weather.temperature)°C")
                    Text("상태: \(weather.description)")
                    Text("풍속: \(String(format: "%.1f", weather.windSpeed)) m/s")
                }
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
                
                // 메모 입력 UI 관련 부분 제거
                // Text("메모 (선택 사항):")
                //     .font(.headline)
                // TextField("간단한 메모 입력...", text: $memoText, axis: .vertical)
                //     .lineLimit(5...10)
                //     .frame(minHeight: 100, maxHeight: 200)
                //     .padding(5)
                //     .border(Color(UIColor.systemGray4), width: 1)
                //     .cornerRadius(5)
                
                Text("위의 '확인 및 저장' 버튼을 누르면 현재 표시된 날씨 정보가 메모 없이 기록됩니다.")
                    .font(.callout)
                    .padding(.vertical)

                Spacer()
            }
            .padding()
            .navigationTitle("날씨 기록 확인")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("확인 및 저장") { // 버튼 이름 변경
                        saveLogWithoutMemoAndDismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    private func saveLogWithoutMemoAndDismiss() {
        weatherLogManager.addLog(
            weather: weather,
            locationName: weather.location,
            memo: nil // 메모를 nil로 전달하여 저장
        )
        dismiss()
    }
}

// Preview는 필요시 업데이트
// struct MemoInputView_Previews: PreviewProvider {
//    static var previews: some View {
//        let dummyWeather = Weather(...) // 더미 데이터 생성
//        MemoInputView(weather: dummyWeather)
//            .environmentObject(WeatherLogManager())
//    }
// }
