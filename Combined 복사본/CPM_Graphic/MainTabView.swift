//
//  MainTabView.swift
//  CPM_Graphic
//
//  Created by 성준영 on 6/1/25.
//

// MainTabView.swift

import SwiftUI

struct MainTabView: View {
    @Environment(\.modelContext) var modelContext // ProjectActivitiesView에 필요할 수 있음

    var body: some View {
        TabView {
            ProjectActivitiesView() // 기존 CPM의 ContentView
                .tabItem {
                    Label("프로젝트 관리", systemImage: "list.bullet.rectangle")
                }

            WeatherDashboardView() // 기존 날씨의 ContentView
                .tabItem {
                    Label("날씨 정보", systemImage: "cloud.sun")
                }
        }
    }
}
