// EditActivityView.swift

import SwiftUI
import SwiftData

struct EditActivityView: View {
    @Binding var navigationPath: NavigationPath
    @Bindable var activity: Activity

    // 상태 변수들은 그대로 유지
    @State private var selectedPredecessorId: Int?
    @State private var selectedSuccessorId: Int?
    @State private var markupInput: String = ""

    // Query도 그대로 유지
    @Query(sort: [
        SortDescriptor(\Activity.id),
        SortDescriptor(\Activity.name)
    ]) var activities: [Activity]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    // UI 구성을 위한 내부 상수
    private let sectionSpacing: CGFloat = 20
    private let itemSpacing: CGFloat = 12
    private let cardBackgroundColor = Color(.systemGray6).opacity(0.8) // 카드 배경색 (앱 배경이 비치도록 약간 투명하게)
    private let cardCornerRadius: CGFloat = 12

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: sectionSpacing) {
                
                // --- DELETE BUTTON 섹션 ---
                StyledSection {
                    Button(role: .destructive) {
                        deleteActivity()
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "trash.fill")
                            Text("Delete Activity")
                                .font(.custom("HelveticaNeue-Bold", size: 16))
                            Spacer()
                        }
                        .padding(.vertical, 8) // 버튼 내부 패딩
                        .foregroundColor(.red)
                    }
                }

                // --- GENERAL INFORMATION 섹션 ---
                StyledSection(header: "GENERAL INFORMATION") {
                    CustomDataRow(label: "ID:") {
                        TextField("ID", value: $activity.id, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(PlainTextFieldStyle()) // 기본 TextField 스타일 변경
                    }
                    CustomDivider()
                    CustomDataRow(label: "Name:") {
                        TextField("Name", text: $activity.name)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    CustomDivider()
                    CustomDataRow(label: "Duration:") {
                        TextField("Duration (days)", value: $activity.duration, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                }

                // --- COST (USD) 섹션 ---
                StyledSection(header: "COST (USD)") {
                    CustomDataRow(label: "Material Cost:") {
                        TextField("0.00", value: $activity.materialCost, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    CustomDivider()
                    CustomDataRow(label: "Equipment Cost:") {
                        TextField("0.00", value: $activity.equipmentCost, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    CustomDivider()
                    CustomDataRow(label: "Number of Workers:") {
                        TextField("0", value: $activity.laborCount, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    CustomDivider()
                    CustomDataRow(label: "Wage per Hour:") {
                        TextField("0.00", value: $activity.hourlyWage, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    CustomDivider()
                    CustomDisplayRow(label: "Labor Cost:", value: String(format: "$%.2f", activity.laborCost))
                    CustomDivider()
                    CustomDisplayRow(label: "Direct Cost:", value: String(format: "$%.2f", activity.directCost), isBold: true)
                    CustomDivider()
                    CustomDataRow(label: "Overhead Cost:") {
                        TextField("0.00", value: $activity.overheadCost, format: .currency(code: "USD"))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    CustomDivider()
                    CustomDisplayRow(label: "Subtotal:", value: String(format: "$%.2f", activity.subtotal), isBold: true)
                    CustomDivider()
                    CustomDataRow(label: "Markup (%):") {
                        TextField("0.00", text: $markupInput)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(PlainTextFieldStyle())
                            .onChange(of: markupInput) { newValue in
                                if let value = Double(newValue) {
                                    activity.markup = value / 100.0
                                } else {
                                    activity.markup = 0
                                }
                            }
                    }
                    CustomDivider()
                    CustomDisplayRow(label: "Total Billed:", value: String(format: "$%.2f", activity.totalBilled), isBold: true)
                }

                // --- PREDECESSORS 섹션 ---
                StyledSection(header: "PREDECESSORS") {
                    if activity.predecessors.isEmpty {
                        Text("No predecessors")
                            .font(.custom("HelveticaNeue-Italic", size: 16))
                            .foregroundColor(.gray)
                            .padding(.vertical, itemSpacing)
                    } else {
                        ForEach(activity.predecessors.sorted(by: { $0.id < $1.id }), id: \.id) { pred in
                            HStack {
                                Text(pred.name.isEmpty ? "Unnamed Predecessor (\(pred.id))" : pred.name)
                                Spacer()
                                Button {
                                    if let index = activity.predecessors.firstIndex(where: {$0.id == pred.id}) {
                                        removePredecessor(at: IndexSet(integer: index)) // 정렬된 배열 기준이 아닌 원본 배열 기준 인덱스 필요
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, itemSpacing / 2)
                            if pred.id != activity.predecessors.sorted(by: { $0.id < $1.id }).last?.id {
                                CustomDivider()
                            }
                        }
                    }
                    CustomDivider()
                    HStack { // Picker를 위한 커스텀 행
                        Text("Add Predecessor:")
                            .font(.custom("HelveticaNeue", size: 16))
                        Spacer()
                        Picker("Select New Predecessor", selection: $selectedPredecessorId) {
                            Text("None").tag(nil as Int?)
                            ForEach(activities.filter { $0.id != activity.id }, id: \.id) { act in // 기존 필터 유지
                                Text("\(act.name.isEmpty ? "Unnamed (\(act.id))" : act.name) (\(act.id))").tag(act.id as Int?)
                            }
                        }
                        .labelsHidden()
                        .tint(.orange) // Picker 강조색
                    }
                    .padding(.vertical, itemSpacing / 2)
                    .onChange(of: selectedPredecessorId) { addPredecessor() }
                }
                
                // --- SUCCESSORS 섹션 ---
                StyledSection(header: "SUCCESSORS") {
                    if activity.successors.isEmpty {
                        Text("No successors")
                            .font(.custom("HelveticaNeue-Italic", size: 16))
                            .foregroundColor(.gray)
                            .padding(.vertical, itemSpacing)
                    } else {
                        ForEach(activity.successors.sorted(by: { $0.id < $1.id }), id: \.id) { succ in
                            HStack {
                                Text(succ.name.isEmpty ? "Unnamed Successor (\(succ.id))" : succ.name)
                                Spacer()
                                Button {
                                     if let index = activity.successors.firstIndex(where: {$0.id == succ.id}) {
                                        removeSuccessor(at: IndexSet(integer: index))
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, itemSpacing / 2)
                            if succ.id != activity.successors.sorted(by: { $0.id < $1.id }).last?.id {
                                CustomDivider()
                            }
                        }
                    }
                    CustomDivider()
                    HStack { // Picker를 위한 커스텀 행
                        Text("Add Successor:")
                            .font(.custom("HelveticaNeue", size: 16))
                        Spacer()
                        Picker("Select New Successor", selection: $selectedSuccessorId) {
                            Text("None").tag(nil as Int?)
                            ForEach(activities.filter { $0.id != activity.id }, id: \.id) { act in // 기존 필터 유지
                                Text("\(act.name.isEmpty ? "Unnamed (\(act.id))" : act.name) (\(act.id))").tag(act.id as Int?)
                            }
                        }
                        .labelsHidden()
                        .tint(.orange)
                    }
                    .padding(.vertical, itemSpacing / 2)
                    .onChange(of: selectedSuccessorId) { addSuccessor() }
                }

            }
            .padding() // ScrollView 컨텐츠 전체에 대한 패딩
        }
        .navigationTitle("Edit Activity")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.clear) // ScrollView 자체의 배경을 투명하게 하여 앱 배경이 보이도록
        .onAppear {
            markupInput = String(format: "%.2f", activity.markup * 100)
        }
    }

    // Helper 함수들은 기존 로직을 최대한 유지 (관계 설정 부분은 이전 코드 참고)
    private func deleteActivity() {
        context.delete(activity)
        do { try context.save() } catch { print("Failed to delete activity: \(error)") }
        dismiss()
    }

    private func addPredecessor() {
        guard let id = selectedPredecessorId, let pred = activities.first(where: { $0.id == id }) else { return }
        if !activity.predecessors.contains(where: { $0.id == pred.id }) {
            activity.predecessors.append(pred)
            if !pred.successors.contains(where: { $0.id == activity.id }) { pred.successors.append(activity) }
        }
        selectedPredecessorId = nil
    }

    private func removePredecessor(at offsets: IndexSet) { // ForEach에서 직접 호출 시 주의 필요 (정렬된 리스트 기준)
        // 실제 삭제 로직은 activity.predecessors 에서 직접 해당 요소를 찾아 제거해야 합니다.
        // 아래는 예시이며, 정확한 인덱스 매칭이 필요합니다.
        // ForEach가 sorted된 배열을 사용하므로, 원본 배열에서 올바른 객체를 찾아 제거해야 합니다.
        let sortedPredecessors = activity.predecessors.sorted(by: { $0.id < $1.id })
        offsets.forEach { index in
            let predecessorToRemove = sortedPredecessors[index]
            predecessorToRemove.successors.removeAll { $0.id == activity.id }
            activity.predecessors.removeAll { $0.id == predecessorToRemove.id }
        }
    }

    private func addSuccessor() {
        guard let id = selectedSuccessorId, let succ = activities.first(where: { $0.id == id }) else { return }
        if !activity.successors.contains(where: { $0.id == succ.id }) {
            activity.successors.append(succ)
            if !succ.predecessors.contains(where: { $0.id == activity.id }) { succ.predecessors.append(activity) }
        }
        selectedSuccessorId = nil
    }

    private func removeSuccessor(at offsets: IndexSet) {
        let sortedSuccessors = activity.successors.sorted(by: { $0.id < $1.id })
        offsets.forEach { index in
            let successorToRemove = sortedSuccessors[index]
            successorToRemove.predecessors.removeAll { $0.id == activity.id }
            activity.successors.removeAll { $0.id == successorToRemove.id }
        }
    }
}

// --- Helper Views for Custom Styling ---

// 섹션 스타일을 위한 뷰 빌더
struct StyledSection<Content: View>: View {
    var header: String?
    @ViewBuilder var content: () -> Content
    private let cardBackgroundColor = Color(UIColor.systemBackground).opacity(0.7) // 시스템 배경색 기반
    private let cardCornerRadius: CGFloat = 12

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let header = header {
                Text(header)
                    .font(.custom("HelveticaNeue-Bold", size: 18))
                    .foregroundColor(.orange) // 주황색 강조
                    .padding(.bottom, 5)
            }
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(cardBackgroundColor)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2) // 약간의 그림자 효과
        )
    }
}

// 데이터 입력/표시를 위한 커스텀 행 (레이블 + 컨텐츠)
struct CustomDataRow<Content: View>: View {
    let label: String
    @ViewBuilder var content: () -> Content
    private let itemSpacing: CGFloat = 12

    var body: some View {
        HStack {
            Text(label)
                .font(.custom("HelveticaNeue", size: 16)) // 기존 폰트 활용
                .foregroundColor(Color(.label)) // 시스템 기본 텍스트 색상
            Spacer()
            content()
                .font(.custom("HelveticaNeue", size: 16))
        }
        .padding(.vertical, itemSpacing / 2)
    }
}

// 단순히 텍스트 값을 표시하기 위한 커스텀 행
struct CustomDisplayRow: View {
    let label: String
    let value: String
    var isBold: Bool = false
    private let itemSpacing: CGFloat = 12

    var body: some View {
        HStack {
            Text(label)
                .font(.custom("HelveticaNeue", size: 16))
                .fontWeight(isBold ? .bold : .regular)
            Spacer()
            Text(value)
                .font(.custom("HelveticaNeue", size: 16))
                .fontWeight(isBold ? .bold : .regular)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, itemSpacing / 2)
    }
}

// 커스텀 구분선
struct CustomDivider: View {
    var body: some View {
        Divider().background(Color(.systemGray4))
    }
}
