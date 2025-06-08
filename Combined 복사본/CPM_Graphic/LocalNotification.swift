//
//  LocalNotification.swift
//  CPM_Graphic
//
//  Created by snlcom on 6/2/25.
//

import Foundation
import UserNotifications
import SwiftUI

// MARK: - 알림 관리자 클래스 (싱글톤 형태로 사용)
class LocalNotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    static let shared = LocalNotificationManager()
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        requestAuthorization()
    }
    
    // MARK: - 알림 권한 요청
    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("알림 권한 요청 오류: \(error.localizedDescription)")
            } else {
                print(granted ? "✅ 알림 권한 허용됨" : "❌ 알림 권한 거부됨")
            }
        }
    }
    
    // MARK: - 날씨 조건에 따라 알림 보내기
    func sendWeatherWarningNotificationIfNeeded(weather: Weather) {
        var shouldNotify = false

        // 1. 날씨 상태 확인
        if ["Rain", "Drizzle", "Snow", "Fog", "Mist", "Haze"].contains(weather.main) {
            shouldNotify = true
        }

        // 2. 온도 확인
        if let temp = Double(weather.temperature), temp >= 33.0 || temp <= 5.0 {
            shouldNotify = true
        }

        // 3. 풍속 확인
        if weather.windSpeed >= 10.0 {
            shouldNotify = true
        }

        if shouldNotify {
            sendNotification(title: "⚠️ 날씨 경고", body: "현재 날씨로 인해 건설 작업이 불가합니다.")
        }
    }

    // MARK: - 실제 알림 전송
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("알림 등록 실패: \(error.localizedDescription)")
            } else {
                print("📣 알림 등록 완료")
            }
        }
    }

    // MARK: - 앱이 포그라운드에 있을 때 알림 표시 옵션 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
