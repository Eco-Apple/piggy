//
//  ContentView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/1/24.
//

import SwiftUI

struct HomeView: View {    
    @State private var isAddViewPresented = false
    
    @State private var sortDescriptors: [SortDescriptor<Expense>] = [
        SortDescriptor(\Expense.createdDate, order: .reverse),
        SortDescriptor(\Expense.name)
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                ExpenseListView(sortDescriptors: sortDescriptors)
            }
            .navigationTitle("Budget Tracker")
            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    EditButton()
//                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu("Sort", systemImage: "arrow.up.arrow.down") {
                        Picker("Sort", selection: $sortDescriptors){
                            Text("Sort by date")
                                .tag([
                                    SortDescriptor(\Expense.createdDate, order: .reverse),
                                    SortDescriptor(\Expense.name)
                                ])
                            Text("Sort by name")
                                .tag([
                                    SortDescriptor(\Expense.name),
                                    SortDescriptor(\Expense.createdDate, order: .reverse)
                                ])
                        }
                    }
                    
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

