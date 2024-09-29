//
//  AddBudgetView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 9/7/24.
//

import StoreKit
import SwiftUI

struct AddBudgetView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @AppStorage("isBudgetsEmpty") var isBudgetsEmpty = true
    @AppStorage("totalWeekBudgets") var totalWeekBudgets = "0.0"
    
    @AppStorage("isIncomesEmpty") var isIncomesEmpty = true
    @AppStorage("totalWeekIncomes") var totalWeekIncomes = "0.0"
    
    @AppStorage("isExpensesEmpty") var isExpensesEmpty = true
    @AppStorage("totalWeekExpenses") var totalWeekExpenses = "0.0"
    
    @State var title: String = ""
    @State var note: String = ""
    @State var date: Date = .now
    @State var expenses = [Expense]()
    @State var incomes = [Income]()
    
    @State private var isTimeEnabled: Bool = false
    
    @State private var isAddExpensePresented: Bool = false
    @State private var isAddIncomePresented: Bool = false
    
    @FocusState private var isFocus: Bool
    
    var currencySymbol = Locale.current.currencySymbol ?? ""
    
    var removeIncome: Bool = false
    var removeExpense: Bool = false
    
    var callback: (Budget) -> Void = { _ in }
    
    var isConfirmDisabled: Bool {
        guard title.isNotEmpty else { return true }
        
        return false
    }
    
    var totalIncome: Decimal {
        incomes.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpense: Decimal {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                DatePicker(
                    "Date",
                    selection: $date,
                    displayedComponents: isTimeEnabled ? [.date, .hourAndMinute] : .date
                )

                Toggle(isOn: $isTimeEnabled) {
                    Text("Time")
                }
                
                Section {
                    TextField("Title", text: $title)
                    TextEditor(text: $note)
                        .placeHolder("Note", text: $note)
                        .frame(height: 150)
                }
                
                
                if !removeIncome {
                    Section {
                        Button {
                            isAddIncomePresented = true
                        } label: {
                            InfoTextView(label: "Add Income", currency: totalIncome, isButton: true)
                        }
                        
                        ForEach(incomes) { income in
                            InfoTextView(label: income.title, currency: income.amount)
                        }
                    }
                }
                
                if !removeExpense {
                    Section {
                        Button {
                            isAddExpensePresented = true
                        } label: {
                            InfoTextView(label: "Add Expense", currency: totalExpense, isButton: true)
                        }
                        
                        
                        ForEach(expenses) { income in
                            InfoTextView(label: income.title, currency: income.amount)
                        }
                        
                    }
                }
            }
            .listSectionSpacing(.compact)
            .navigationTitle("New Budget")
            .scrollBounceBehavior(.basedOnSize)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: addEntry).disabled(isConfirmDisabled)
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
            }
            .sheet(isPresented: $isAddIncomePresented) {
                AddIncomeView(saveLater: true, removeBudget: true) { income in
                    incomes.append(income)
                }
            }
            .sheet(isPresented: $isAddExpensePresented) {
                AddExpenseView(saveLater: true, removeBudget: true) { expense in
                    expenses.append(expense)
                }
            }
        }
    }
    
    func addEntry() {
        let newBudget = Budget(title: title, note: note, date: date, createdDate: .now, updatedDate: .now, isTimeEnabled: isTimeEnabled)
        
        newBudget.save(incomes: incomes, expenses: expenses, modelContext: modelContext)
        callback(newBudget)
        dismiss()
    }
}

#Preview {
    return AddBudgetView()
}
