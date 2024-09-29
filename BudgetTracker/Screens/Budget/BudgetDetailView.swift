//
//  BudgetView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 9/7/24.
//

import SwiftData
import SwiftUI

struct BudgetDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var note: String = ""
    @State private var date: Date = .now
    
    @State private var isTimeEnabled: Bool = false
    @State private var isEdit: Bool = false
    
    @Bindable var budget: Budget
    
    var currencySymbol = Locale.current.currencySymbol ?? ""
    
    var body: some View {
        Form {
            Section("Details") {
                if isEdit == false {
                    InfoTextView(label: "Title", text: title)
                    InfoTextView(label: "Date", date: date, style: isTimeEnabled ? .dateAndTime : .dateOnly)
                } else {
                    TextField("Title", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: isTimeEnabled ? [.date, .hourAndMinute] : .date)
                    
                    Toggle(isOn: $isTimeEnabled) {
                        Text("Time")
                    }
                }
                    
            }
            if isEdit || note.isNotEmpty {
                Section("Note"){
                    if !isEdit {
                        Text(note)
                            .frame(height: 150, alignment: .topLeading)
                    } else {
                        TextEditor(text: $note)
                            .frame(height: 150)
                            .offset(x: -5, y: -8.5)
                    }
                }
            }
            
            Section {
                InfoTextView(label: "Expenses", currency: budget.totalExpenses, isLink: true)
                InfoTextView(label: "Incomes", currency: budget.totalIncomes, isLink: true)
            }
            
            InfoTextView(label: "Total Budget", currency: budget.totalBudget)
        }
        .navigationTitle("Budget")
        .scrollBounceBehavior(.basedOnSize)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isEdit {
                    Button("Done") {
                        budget.title = title
                        budget.note = note
                        budget.date = date
                        budget.isTimeEnabled = isTimeEnabled
                        budget.updatedDate = .now
                        isEdit.toggle()
                    }
                    .disabled(isDoneButtonDisabled())
                } else if isEdit == false {
                    Button("Edit" ) {
                        isEdit.toggle()
                    }
                }
            }
        }
    }
    
    init(_ budget: Budget) {
        self.budget = budget
        
        self._title = State(initialValue: budget.title)
        self._note = State(initialValue: budget.note)
        self._date = State(initialValue: budget.date!)
        self._isTimeEnabled = State(initialValue: budget.isTimeEnabled)
    }
    
    func isDoneButtonDisabled() -> Bool {
        
        guard title != budget.title || date != budget.date || note != budget.note else { return true }
        
        guard title.isNotEmpty else { return true }
        
        return false
    }
        
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Budget.self, configurations: config)
        let example = Budget.previewItem
        
        return BudgetDetailView(example)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
