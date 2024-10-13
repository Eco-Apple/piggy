//
//  BudgetView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 9/7/24.
//

import SwiftData
import SwiftUI

struct BudgetDetailView: View {
    @Environment(\.navigate) var navigate
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var note: String = ""
    @State private var date: Date = .today
    
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
                Button {
                    navigate(.expense(.seeMore(title: "Expenses", expenses: budget.expenses, canAdd: true, passedBudget: budget)))
                } label: {
                    InfoTextView(label: "Expense", currency: budget.totalExpense, isLink: true, prefix: "- ", currencyColor: .expenseFontColor(amount: budget.totalExpense))
                }
                Button {
                    navigate(.income(.seeMore(title: "Incomes", incomes: budget.incomes, canAdd: true, passedBudget: budget)))
                } label: {
                    InfoTextView(label: "Income", currency: budget.totalIncome, isLink: true, prefix: "+ ", currencyColor: .incomeFontColor(amount: budget.totalIncome))
                }
            }
            
            InfoTextView(label: "Total Budget", currency: budget.totalBudget, currencyColor: .budgetFontColor(amount: budget.totalBudget))
        }
        .navigationTitle("Budget")
        .navigationBarTitleDisplayMode(.inline)
        .scrollBounceBehavior(.basedOnSize)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isEdit {
                    Button("Done", action: done)
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
    
    func done() {
        budget.edit(title: title, note: note, date: date, isTimeEnabled: isTimeEnabled)
        isEdit.toggle()
    }
    
    func isDoneButtonDisabled() -> Bool {
        
        guard title != budget.title || date != budget.date || note != budget.note || isTimeEnabled != budget.isTimeEnabled else { return true }
        
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
