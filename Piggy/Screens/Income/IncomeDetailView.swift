//
//  BudgetView.swift
//  Piggy
//
//  Created by Jerico Villaraza on 9/7/24.
//

import SwiftData
import SwiftUI

struct IncomeDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    @Query var budgets: [Budget]
    
    @State private var title: String = ""
    @State private var note: String = ""
    @State private var amount: Decimal? = nil
    @State private var date: Date = .today
    @State private var budget: Budget? = nil
    
    @State private var isTimeEnabled: Bool = false
    @State private var isEdit: Bool = false
    
    @Bindable var income: Income
    
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
                    DatePicker("Date", selection: $date, in: ...Date(), displayedComponents: isTimeEnabled ? [.date, .hourAndMinute] : .date)
                    
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
        .navigationTitle("Income")
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
    
    init(_ income: Income) {
        self.income = income
        
        _title = State(initialValue: income.title)
        _note = State(initialValue: income.note)
        _amount = State(initialValue: income.amount)
        _date = State(initialValue: income.date)
        _isTimeEnabled = State(initialValue: income.isTimeEnabled)
        _budget = State(initialValue: income.budget)
    }
    
    
    func done() {
        income.edit(title: title, note: note, amount: amount!, date: date, isTimeEnabled: isTimeEnabled, budget: budget!)
        
        isEdit.toggle()
    }
    
    func isDoneButtonDisabled() -> Bool {
        guard title != income.title || amount != income.amount || date != income.date || note != income.note || budget != income.budget || isTimeEnabled != income.isTimeEnabled else { return true }
        
        guard title.isNotEmpty else { return true }
        guard let amount, amount >= 0 else { return true }
        
        
        return false
    }
        
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Income.self, configurations: config)
        let example = Income.previewItem
        
        return IncomeDetailView(example)
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
