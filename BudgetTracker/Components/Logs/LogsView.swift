//
//  LogsView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 10/9/24.
//

import SwiftData
import SwiftUI

struct LogsView: View {
    @Query var budgets: [Budget]
    @Query var expenses: [Expense]
    @Query var incomes: [Income]
    
    
    @AppStorage("isBudgetsEmpty") var isBudgetsEmpty = true
    @AppStorage("totalBudget") var totalBudget = "0.0"
    
    @AppStorage("isWeekExpenseEmpty") var isWeekExpenseEmpty = true
    @AppStorage("totalWeekExpenses") var totalWeekExpenses = "0.0"
    
    @AppStorage("isWeekIncomeEmpty") var isWeekIncomeEmpty = true
    @AppStorage("totalWeekIncomes") var totalWeekIncomes = "0.0"
    
    @AppStorage("expenseFirstDayOfWeek") var expenseFirstDayOfWeek = ""
    @AppStorage("incomeFirstDayOfWeek") var incomeFirstDayOfWeek = ""
        
    var body: some View {
        List {
            Section {
                InfoTextView(label: "Budget", value: budgets.count)
                InfoTextView(label: "Expense", value: expenses.count)
                InfoTextView(label: "Income", value: incomes.count)
            }
            
            Section {
                InfoTextView(label: "totalBudget", currency: Decimal(string: totalBudget)!)
                InfoTextView(label: "totalWeekExpenses", currency: Decimal(string: totalWeekExpenses)!)
                InfoTextView(label: "totalWeekIncomes", currency: Decimal(string: totalWeekIncomes)!)
            }
            
            Section {
                InfoTextView(label: "isBudgetsEmpty", status: isBudgetsEmpty)
                InfoTextView(label: "isWeekExpenseEmpty", status: isWeekExpenseEmpty)
                InfoTextView(label: "isWeekIncomeEmpty", status: isWeekIncomeEmpty)
            }
            
            Section {
                InfoTextView(label: "expense", text: expenseFirstDayOfWeek.toDate?.format(.dateAndTime) ?? "")
                InfoTextView(label: "income", text: incomeFirstDayOfWeek.toDate?.format(.dateAndTime) ?? "")
            }
        }
    }
}

#Preview {
    LogsView()
}
