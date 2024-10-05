//
//  ExpenseView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/25/24.
//

import SwiftData
import SwiftUI

struct ExpenseDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    @Query var budgets: [Budget]
    
    @State private var title: String = ""
    @State private var note: String = ""
    @State private var amount: Decimal? = nil
    @State private var date: Date = .now
    @State private var budget: Budget? = nil
    
    @State private var isEdit: Bool = false
    @State private var isTimeEnabled: Bool = false
    
    @Bindable var expense: Expense
    
    var body: some View {
        Form {
            Section("Details") {
                if isEdit == false {
                    InfoTextView(label: "Title", text: title)
                    InfoTextView(label: "Amount", currency: amount!)
                    InfoTextView(label: "Date", date: date, style: isTimeEnabled ? .dateAndTime : .dateOnly)
                } else {
                    TextField("Title", text: $title)
                    CurrencyField("eg. 10.00", value: $amount)
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
            
            if isEdit == false {
                InfoTextView(label: "Budget", text: budget?.title ?? "")
            } else {
                Picker("Budget", selection: $budget) {
                    ForEach(budgets) { budget in
                        Text(budget.title).tag(budget)
                    }
                }
            }
        }
        .listSectionSpacing(.compact)
        .navigationTitle("Expense")
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
    
    init(_ expense: Expense) {
        self.expense = expense
        
        _title = State(initialValue: expense.title)
        _note = State(initialValue: expense.note)
        _amount = State(initialValue: expense.amount)
        _date = State(initialValue: expense.date!)
        _isTimeEnabled = State(initialValue: expense.isTimeEnabled)
        _budget = State(initialValue: expense.budget)

        guard let fromToDate = setupDate() else { return }
        
        let normalizedFromDate = fromToDate.from
        let normalizedToDate = fromToDate.to
        
        let fetchDescriptor = FetchDescriptor<Budget>(predicate: #Predicate<Budget> { budget in
            if let budgetDate = budget.date {
                return budgetDate >= normalizedFromDate && budgetDate <= normalizedToDate
            } else {
                return false
            }
            
        })
        
        _budgets = Query(fetchDescriptor)
    }
    
    func done() {
        expense.edit(title: title, note: note, amount: amount!, date: date, isTimeEnabled: isTimeEnabled, budget: budget!)
        
        isEdit.toggle()
    }
    
    func setupDate() -> (from: Date, to: Date)? {
        let today = Date.now
        let calendar = Calendar.current

        let weekday = calendar.component(.weekday, from: today)
        

        let daysToMonday = (weekday == 1 ? -6 : 2 - weekday)

        guard let monday = calendar.date(byAdding: .day, value: daysToMonday, to: today)?.localStartOfDate else { return nil }
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: today)?.localStartOfDate else { return nil }
         
        return (monday, nextDay)
    }
    
    func isDoneButtonDisabled() -> Bool {
        
        guard expense.budget == budget else { return false }
        
        guard title != expense.title || amount != expense.amount || date != expense.date || note != expense.note else { return true }
        
        guard title.isNotEmpty else { return true }
        guard let amount, amount >= 0 else { return true }
        
        return false
    }
        
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Expense.self, configurations: config)
        let example = Expense.previewItem
        
        return ExpenseDetailView(example)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
