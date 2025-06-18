// SimpleCalendar.swift

import SwiftUI

struct SimpleCalendarView: View {
    @State private var selectedDate = Date()

    var body: some View {
        VStack(spacing: 20) {
            Text(selectedDate, style: .date)
                .font(.title2)
                .foregroundColor(.black)
                .padding(.top, 20)

            DatePicker(
                "Select Date", // Translated from "날짜 선택"
                selection: $selectedDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .accentColor(.blue)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            .padding()
        }
        .background(Color.white.ignoresSafeArea())
    }
}

struct SimpleCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleCalendarView()
    }
}
