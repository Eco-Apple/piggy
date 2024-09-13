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
    
    @State private var title: String = ""
    @State private var note: String = ""
    @State private var amount: Decimal? = nil
    @State private var date: Date = .now
    
    @State private var isEdit: Bool = false
    @State private var isTimeEnabled: Bool = false
    
    
    @Bindable var expense: Expense
    
    var currencySymbol = Locale.current.currencySymbol ?? ""
    
    var body: some View {
        Form {
            Section("Details") {
                if isEdit == false {
                    InfoTextView(label: "Title", text: title)
                    InfoTextView(label: "Amount", currency: amount!)
                    InfoTextView(label: "Date", date: date, style: isTimeEnabled ? .dateAndTime : .dateOnly)
                } else {
                    TextField("Title", text: $title)
                    CurrencyField("eg. \(currencySymbol)10.00", value: $amount)
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
        }
        .navigationTitle("Expense")
        .scrollBounceBehavior(.basedOnSize)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isEdit {
                    Button("Done") {
                        expense.title = title
                        expense.note = note
                        expense.amount = amount!
                        expense.date = date
                        expense.isTimeEnabled = isTimeEnabled
                        expense.updatedDate = .now
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
    
    init(_ expense: Expense) {
        self.expense = expense
        
        _title = State(initialValue: expense.title)
        _note = State(initialValue: expense.note)
        _amount = State(initialValue: expense.amount)
        _date = State(initialValue: expense.date!)
        _isTimeEnabled = State(initialValue: expense.isTimeEnabled)
    }
    
    func isDoneButtonDisabled() -> Bool {
        
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
