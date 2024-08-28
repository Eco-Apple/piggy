//
//  ContentView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/1/24.
//

import SwiftUI

struct HomeView: View {    
    @State private var isAddViewPresented = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ExpenseListView()
            }
            .navigationTitle("Budget Tracker")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
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

