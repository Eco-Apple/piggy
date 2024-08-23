//
//  ContentView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/1/24.
//

import SwiftUI

struct HomeView: View {
    @State private var expenses = Expenses()
    
    var body: some View {
        NavigationStack {
            VStack {
                if expenses.items.isNotEmpty{
                    List {
                        ForEach(expenses.items) { expense in
                            ExpenseView(expense)
                        }
                        .onDelete(perform: { indexSet in
                            expenses.items.remove(atOffsets: indexSet)
                        })
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
                    NavigationLink {
                        AddExpenseView(expenses: expenses)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }

        }
    }
}

#Preview {
    HomeView()
}

