//
//  ProjectResultView.swift
//  CPM_Graphic
//
//  Created by 성준영 on 5/19/25.
//

import SwiftUI

// Helper struct to hold parsed data for a single activity
fileprivate struct ActivityResultData: Identifiable {
    let id = UUID()
    let title: String
    var details: [String]
}

// Helper struct for the entire parsed result
fileprivate struct ParsedProjectResult {
    let activityData: [ActivityResultData]
    let criticalPathInfo: String
}

struct ProjectResultView: View {
    let resultString: String
    @State private var isShowingGraphicalResults = false
    @StateObject var activityPositions = ActivityPositions()

    // The parsed data is now a computed property
    private var parsedResult: ParsedProjectResult {
        parseResultString(resultString)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // MARK: - Activity Cards
                ForEach(parsedResult.activityData) { activity in
                    VStack(alignment: .leading, spacing: 8) {
                        // Card Header: Activity ID and Name
                        Text(activity.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.orange)

                        Divider()

                        // Card Body: Details
                        ForEach(activity.details, id: \.self) { detailLine in
                            HStack {
                                let parts = detailLine.components(separatedBy: ":")
                                if parts.count == 2 {
                                    Text(parts[0])
                                        .font(.system(size: 16))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(parts[1].trimmingCharacters(in: .whitespaces))
                                        .font(.system(size: 16, weight: .medium))
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground).opacity(0.7))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                }
                
                // MARK: - Critical Path Card
                if !parsedResult.criticalPathInfo.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                         let lines = parsedResult.criticalPathInfo.components(separatedBy: "\n")
                         Text(lines.first ?? "Critical Paths")
                             .font(.system(size: 18, weight: .bold))
                             .foregroundColor(.red)
                         
                         Divider()
                         
                         Text(lines.dropFirst().joined(separator: "\n"))
                            .font(.system(.body, design: .monospaced))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.systemBackground).opacity(0.7))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                }

                // MARK: - Graphical View Button
                Button("Show Graphical View") {
                    isShowingGraphicalResults = true
                }
                .font(.custom("HelveticaNeue-Bold", size: 18))
                .padding()
                .background(Color.orange.opacity(0.8))
                .cornerRadius(10)
                .foregroundColor(.white)
                .padding(.top)
                .sheet(isPresented: $isShowingGraphicalResults) {
                    GraphicalResultView()
                        .environmentObject(activityPositions)
                }
            }
            .padding()
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
    
    // MARK: - Parsing Function
    /// This function parses the raw string from the Project class into a structured format.
    private func parseResultString(_ result: String) -> ParsedProjectResult {
        // Split the string into the main results and the critical path section.
        let criticalPathSeparator = "Critical Paths"
        let parts = result.components(separatedBy: criticalPathSeparator)
        
        let mainResultString = parts.first ?? ""
        let criticalPathString = parts.count > 1 ? criticalPathSeparator + (parts.last ?? "") : ""
        
        // Process the main activity results into blocks.
        let activityBlocks = mainResultString.components(separatedBy: "\n\n").filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        let activityData = activityBlocks.map { block -> ActivityResultData in
            var lines = block.components(separatedBy: "\n").filter { !$0.isEmpty }
            let title = lines.removeFirst()
            return ActivityResultData(title: title, details: lines)
        }
        
        return ParsedProjectResult(activityData: activityData, criticalPathInfo: criticalPathString.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}
