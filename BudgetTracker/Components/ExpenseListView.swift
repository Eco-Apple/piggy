//
//  ExpenseListView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/27/24.
//

import SwiftData
import SwiftUI

struct ExpenseSectionListView: View {
    @Environment(\.modelContext) var modelContext
    
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
                for index in offsets {
                    let expense = filteredExpenses[index]
                    modelContext.delete(expense)
                }
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
