//
//  AddExpenseView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/10/24.
//

import StoreKit
import SwiftData
import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @AppStorage("isExpensesEmpty") var isExpensesEmpty = true
    @AppStorage("totalWeekExpenses") var totalWeekExpenses = "0.0"
    
    @Query var budgets: [Budget]

    @State private var title: String = ""
    @State private var note: String = ""
    @State private var amount: Decimal? = nil
    @State private var date: Date = .now
    @State private var selectedbudget: Budget?
    
    @State private var isTimeEnabled: Bool = false
    
    @FocusState private var isFocus: Bool
    
    var currencySymbol = Locale.current.currencySymbol ?? ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    CurrencyField("eg. \(currencySymbol)10.00", value: $amount)
                        .focused($isFocus)
                }
                
                Section {
                    Picker("Budget", selection: $selectedbudget) {
                        ForEach(budgets) { budget in
                            Text(budget.title).tag(budget)
                        }
                    }
                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: isTimeEnabled ? [.date, .hourAndMinute] : .date
                    )
                }
                
                Toggle(isOn: $isTimeEnabled) {
                    Text("Time")
                }
                
                Section {
                    TextField("Title", text: $title)
                    TextEditor(text: $note)
                        .placeHolder("Note", text: $note)
                        .frame(height: 150)
                }
            }
            .listSectionSpacing(.compact)
            .navigationTitle("New Expense")
            .scrollBounceBehavior(.basedOnSize)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: addEntry).disabled(isConfirmDisabled())
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFocus = true
                }
                
                selectedbudget = budgets.first
            }
        }
    }
    
    
    init() {
        guard let fromToDate = setupDate() else { return }
        
        
        let normalizedFromDate = Calendar.current.startOfDay(for: fromToDate.from)
        let normalizedToDate = Calendar.current.startOfDay(for: fromToDate.to)
        
        var fetchDescriptor = FetchDescriptor<Budget>(predicate: #Predicate<Budget> { budget in
            if let budgetDate = budget.date {
                return budgetDate >= normalizedFromDate && budgetDate < normalizedToDate
            } else {
                return false
            }
            
        })
        
        _budgets = Query(fetchDescriptor)
    }
    
    
    func setupDate() -> (from: Date, to: Date)? {
        let today = Date.now
        let calendar = Calendar.current

        let weekday = calendar.component(.weekday, from: today)
        

        let daysToMonday = (weekday == 1 ? -6 : 2 - weekday)
        let daysToSunday = (weekday == 1 ? 0 : 8 - weekday)

        guard let monday = calendar.date(byAdding: .day, value: daysToMonday, to: today) else { return nil }
        guard let sunday = calendar.date(byAdding: .day, value: daysToSunday, to: today) else { return nil }
         
        return (monday, sunday)
    }
    

    
    func isConfirmDisabled() -> Bool {
        guard title.isNotEmpty else { return true }
        guard let amount, amount >= 0 else { return true }
        
        return false
    }
    
    func addEntry() {
        let newExpense = Expense(title: title, note: note, amount: amount!,date: date, createdDate: .now, updateDate: .now, isTimeEnabled: isTimeEnabled, budget: selectedbudget!)
        
        totalWeekExpenses = totalWeekExpenses.arithmeticOperation(of: newExpense.amount, .add)!
        
        modelContext.insert(newExpense)
        isExpensesEmpty = false
        dismiss()
    }
}

#Preview {
    return AddExpenseView()
}
