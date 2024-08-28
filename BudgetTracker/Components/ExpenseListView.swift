//
//  ExpenseListView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/27/24.
//

import SwiftData
import SwiftUI

struct ExpenseSectionListView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @State private var isAlertPresented = false
    @State private var expensesToDelete: [Expense] = []
    
    var createDate: Date
    var filteredExpenses: [Expense]
    
    var body: some View {
        Section(createDate.format(.dateOnly, descriptive: true)) {
            
            ForEach(filteredExpenses) { expense in
                NavigationLink(value: expense) {
                    ExpensListItemView(expense: expense)
                }
            }
            .onDelete { offsets in
                expensesToDelete = []
                for index in offsets {
                    let expense = filteredExpenses[index]
                    isAlertPresented = true
                    expensesToDelete.append(expense)
                }
            }
            .alert(isPresented: $isAlertPresented){
                Alert(
                    title: Text("Are you sure you want to delete \(filteredExpenses.getPluralSuffix(singular: "this", plural: "these")) expense\(filteredExpenses.getPluralSuffix(singular: "", plural: "s"))?"),
                    message: Text("You cannot undo this action once done."),
                    primaryButton: .destructive(Text("Delete")) {
                        for expense in expensesToDelete {
                            modelContext.delete(expense)
                        }
                        
                        dismiss()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct ExpenseListView: View {
    @Environment(\.modelContext) var modelContext
    @Query var expenses: [Expense]
    
    let sectionsDate: [Date] = [
        Calendar.current.date(byAdding: .day, value: -2, to: Date.now)!,
        Calendar.current.date(byAdding: .day, value: -3, to: Date.now)!,
        Calendar.current.date(byAdding: .day, value: -4, to: Date.now)!,
    ]
        
    var body: some View {
        if expenses.isNotEmpty{
            List {
                let todayExpenses = expenses.filterByDate(of: Date.now)
                
                let yesterdayExpenses = expenses.filterByDate(of: Calendar.current.date(byAdding: .day, value: -1, to: Date.now)!
                )
                
                if todayExpenses.isNotEmpty {
                    ExpenseSectionListView(createDate: Date.now, filteredExpenses: todayExpenses)
                }
                
                if yesterdayExpenses.isNotEmpty {
                    ExpenseSectionListView(createDate: Calendar.current.date(byAdding: .day, value: -1, to: Date.now)!, filteredExpenses: yesterdayExpenses)
                }

                ForEach(sectionsDate, id: \.self) { date in
                    let filteredExpenses = expenses.filterByDate(of: date)
                    
                    if filteredExpenses.isNotEmpty {
                        ExpenseSectionListView(createDate: date, filteredExpenses: filteredExpenses)
                    }
                }
            }
        } else {
            Text("No expenses")
               .foregroundColor(.gray)
               .font(.headline)
        }
    }
}

#Preview {
    ExpenseListView()
}
