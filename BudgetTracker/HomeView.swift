//
//  ContentView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/1/24.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) var modelContext
    @Query var expenses: [Expense]
    
    @State private var isAddViewPresented = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if expenses.isNotEmpty{
                    List {
                        ForEach(expenses) { expense in
                            NavigationLink(value: expense) {
                                ExpensListItemView(expense: expense)
                            }
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                let expense = expenses[index]
                                modelContext.delete(expense)
                            }
                        }
                    }
                } else {
                    Text("No expenses")
                       .foregroundColor(.gray)
                       .font(.headline)
                }
            }
            .navigationTitle("Budget Tracker")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add button", systemImage: "plus") {
                        isAddViewPresented = true
                    }
                }
            }
            .sheet(isPresented: $isAddViewPresented) {
                AddExpenseView()
            }
            .navigationDestination(for: Expense.self) { expense in
                ExpenseView(expense)
            }
            

        }
    }
}

#Preview {
    HomeView()
}

