// MainTabView.swift

import SwiftUI

struct MainTabView: View {
    @Environment(\.modelContext) var modelContext // ProjectActivitiesView에 필요할 수 있음

    var body: some View {
        TabView {
            ProjectActivitiesView() // 기존 CPM의 ContentView
                .tabItem {
                    Label("Project Management", systemImage: "list.bullet.rectangle")
                }

            WeatherDashboardView() // 기존 날씨의 ContentView
                .tabItem {
                    Label("Weather Info", systemImage: "cloud.sun")
                }
        }
    }
}
