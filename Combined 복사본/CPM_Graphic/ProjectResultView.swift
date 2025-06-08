//
//  ProjectResultView.swift
//  CPM_Graphic
//
//  Created by 성준영 on 5/19/25.
//



import SwiftUI

struct ProjectResultView: View {
    let resultString: String
    @State private var isShowingGraphicalResults = false
    @StateObject var activityPositions = ActivityPositions()

    var body: some View {
        ScrollView {
            Text(resultString)
                .font(.custom("HelveticaNeue", size: 16))
                .padding()

            Button("Show Graphical View") {
                isShowingGraphicalResults = true
            }
            .font(.custom("HelveticaNeue-Bold", size: 18))
            .padding()
            .background(Color.orange.opacity(0.8))
            .cornerRadius(10)
            .foregroundColor(.white)
            .sheet(isPresented: $isShowingGraphicalResults) {
                GraphicalResultView()
                    .environmentObject(activityPositions)
            }
        }
        .navigationTitle("Project Results")
        .background(
            Image("ArchitectureBackground")
                .resizable()
                .scaledToFill()
                .opacity(0.15)
                .ignoresSafeArea()
        )
    }
}
