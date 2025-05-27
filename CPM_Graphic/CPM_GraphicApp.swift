// CPM_GraphicApp.swift

import SwiftUI

@main
struct CPM_GraphicApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .accentColor(.orange) // 강조 색상
                .background(
                    Image("ArchitectureBackground")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                )
        }
        .modelContainer(for: Activity.self)
    }
}
