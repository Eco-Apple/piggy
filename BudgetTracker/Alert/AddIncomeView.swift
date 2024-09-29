//
//  AddIncomeView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 9/7/24.
//

import StoreKit
import SwiftData
import SwiftUI

struct AddIncomeView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @AppStorage("isIncomesEmpty") var isIncomesEmpty = true
    @AppStorage("totalWeekIncomes") var totalWeekIncomes = "0.0"
    
    @Query var budgets: [Budget]
    
    @State var title: String = ""
    @State var note: String = ""
    @State var amount: Decimal? = nil
    @State var date: Date = .now
    @State private var selectedBudget: Budget?
    
    @State private var isTimeEnabled: Bool = false
    
    @State private var isAddBudgetPresented: Bool = false
    
    @FocusState private var isFocus: Bool
    
    var currencySymbol = Locale.current.currencySymbol ?? ""
    
    var saveLater: Bool = false
    var removeBudget: Bool = false

    var callback: (Income) -> Void = { _ in }
        
    var body: some View {
        NavigationStack {
            Form {
                Section("Amount") {
                    CurrencyField("eg. \(currencySymbol)10.00", value: $amount)
                        .focused($isFocus)
                }
                                
                Section {
                    DatePicker(
                        "Date",
                        selection: $date,
                        displayedComponents: isTimeEnabled ? [.date, .hourAndMinute] : .date
                    )
                    
                    Toggle(isOn: $isTimeEnabled) {
                        Text("Time")
                    }
                }
                
                Section {
                    TextField("Title", text: $title)
                    TextEditor(text: $note)
                        .placeHolder("Note", text: $note)
                        .frame(height: 150)
                }
                
                if !removeBudget {
                    if selectedBudget != nil {
                        Picker("Budget", selection: $selectedBudget) {
                            ForEach(budgets) { budget in
                                Text(budget.title).tag(budget)
                            }
                        }
                    } else {
                        Button("Add Budget") {
                            isAddBudgetPresented = true
                        }
                    }
                }
            }
            .listSectionSpacing(.compact)
            .navigationTitle("New Income")
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
            .sheet(isPresented: $isAddBudgetPresented) {
                AddBudgetView(removeIncome: true, removeExpense: true) { budget in
                    selectedBudget = budget
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFocus = true
                }
                
                selectedBudget = budgets.first
            }
        }
    }
    
    init(saveLater: Bool = false, removeBudget: Bool = false, callback: @escaping (Income) -> Void = { _ in}) {
        self.callback = callback
        self.saveLater = saveLater
        self.removeBudget = removeBudget
        
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
    
    
    func setupDate() -> (from: Date, to: Date)? {
        let today = Date.now
        let calendar = Calendar.current

        let weekday = calendar.component(.weekday, from: today)
        

        let daysToMonday = (weekday == 1 ? -6 : 2 - weekday)

        guard let monday = calendar.date(byAdding: .day, value: daysToMonday, to: today)?.localStartOfDate else { return nil }
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: today)?.localStartOfDate else { return nil }
         
        return (monday, nextDay)
    }

    
    func isConfirmDisabled() -> Bool {
        guard title.isNotEmpty else { return true }
        guard let amount, amount >= 0 else { return true }
        guard selectedBudget != nil || removeBudget else { return true }
        
        return false
    }
    
    func addEntry() {
        let newIncome = Income(title: title, note: note, amount: amount!,date: date, createdDate: .now, updatedDate: .now, isTimeEnabled: isTimeEnabled, budget: selectedBudget)
        
        if saveLater {
            dismiss()
            
            callback(newIncome)
            return
        }
        
        newIncome.save(selectedBudget: selectedBudget!, modelContext: modelContext)
        dismiss()
        callback(newIncome)
    }
}

#Preview {
    return AddIncomeView()
}
