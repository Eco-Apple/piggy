//
//  AddExpenseView.swift
//  Piggy
//
//  Created by Jerico Villaraza on 8/10/24.
//

import SwiftData
import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(\.requestReview) var requestReview
    
    @AppStorage("isWeekExpenseEmpty") var isWeekExpenseEmpty = true
    @AppStorage("totalWeekExpenses") var totalWeekExpenses = "0.0"
    @AppStorage("reviewExpenseCount") var reviewExpenseCount: Int = 0
    
    @Query var budgets: [Budget]

    @State private var title: String = ""
    @State private var note: String = ""
    @State private var amount: Decimal? = nil
    @State private var date: Date = .today
    @State private var budget: Budget?
    
    @State private var isTimeEnabled: Bool = false
    
    @State private var isAddBudgetPresented: Bool = false
    
    @FocusState private var isFocus: Bool
    
    var saveLater: Bool = false
    var removeBudget: Bool = false
    var passedBudget: Budget? = nil

    var callback: (Expense) -> Void = { _ in }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Amount*") {
                    CurrencyField("eg. 10.00", value: $amount)
                        .focused($isFocus)
                }
                
                Section {
                    DatePicker(
                        "Date",
                        selection: $date,
                        in: ...Date(),
                        displayedComponents: isTimeEnabled ? [.date, .hourAndMinute] : .date
                    )
                    
                    Toggle(isOn: $isTimeEnabled) {
                        Text("Time")
                    }
                }
                
                Section {
                    TextField("Title*", text: $title)
                    TextEditor(text: $note)
                        .placeHolder("Note", text: $note)
                        .frame(height: 150)
                }
                
                if passedBudget == nil && !removeBudget{
                    if budget != nil {
                        Picker("Budget", selection: $budget) {
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
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
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
                AddBudgetView(removeIncome: true, removeExpense: true) { newBudget in
                    budget = newBudget
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isFocus = true
                }
                
                if passedBudget == nil {
                    budget = budgets.first
                }
            }
        }
    }
    
    
    init(saveLater: Bool = false, removeBudget: Bool = false, passedBudget: Budget? = nil, callback: @escaping (Expense) -> Void = { _ in }) {
        self.callback = callback
        self.saveLater = saveLater
        self.removeBudget = removeBudget
        self.passedBudget = passedBudget
        
        if let passedBudget = passedBudget {
            self._budget = State(initialValue: passedBudget)
        }
    }
    
    func isConfirmDisabled() -> Bool {
        guard title.isNotEmpty else { return true }
        guard let amount, amount >= 0 else { return true }
        guard budget != nil || removeBudget else { return true }
        
        return false
    }
    
    func addEntry() {
        
        let newExpense = Expense(title: title, note: note, amount: amount!,date: date, createdDate: .today, updateDate: .today, isTimeEnabled: isTimeEnabled, budget: budget ?? .placeholder)
        
        
        if saveLater {
            dismiss()
            
            callback(newExpense)
            return
        }
        
        newExpense.save(modelContext: modelContext)
        
        reviewExpenseCount += 1
        
        if reviewExpenseCount >= 50 {
            requestReview()
        }
        
        callback(newExpense)
        dismiss()
    }
}

#Preview {
    return AddExpenseView()
}
