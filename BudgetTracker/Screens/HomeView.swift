//
//  ContentView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/1/24.
//

import StoreKit
import SwiftData
import SwiftUI

struct HomeView: View {    
    
    @Environment(\.modelContext) var modelContext
    
    #if DEBUG
    @AppStorage("isExpensesEmpty") var isExpensesEmpty = true
    @AppStorage("isBudgetsEmpty") var isBudgetsEmpty = true
    
    @State var expenseDayCounter: Double = 0
    @State var budgetDayCounter: Double = 0
    #endif
    
    @State private var isAddViewPresented = false
    
    @State private var expenseSortDescriptors: [SortDescriptor<Expense>] = [
        SortDescriptor(\Expense.createdDate, order: .reverse),
        SortDescriptor(\Expense.title)
    ]
    
    @State private var budgetSortDescriptors: [SortDescriptor<Budget>] = [
        SortDescriptor(\Budget.createdDate, order: .reverse),
        SortDescriptor(\Budget.title)
    ]

    
    @State private var selectedSegment: HomeViewSegments = .expense
    
    var body: some View {
        Navigation {
            VStack(alignment: .leading) {
                
                if selectedSegment == .expense {
                    ExpenseListView(sortDescriptors: expenseSortDescriptors)
                } else if selectedSegment == .budget {
                    BudgetListView(sortDescriptors: budgetSortDescriptors)
                }
                
                Picker("Select a segment", selection: $selectedSegment) {
                    Text("Expenses").tag(HomeViewSegments.expense)
                    Text("Budget").tag(HomeViewSegments.budget)
                 }
                 .pickerStyle(SegmentedPickerStyle())
                 .frame(width: 200)
                 .padding()
            }
            .scrollBounceBehavior(.basedOnSize)
            .toolbar {
                
                #if DEBUG
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("add mock data", systemImage: "flame", action: addMockData)
                    Button("delete all data", systemImage: "trash", action: deleteAlldata)
                }
                #endif
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu("Sort", systemImage: "arrow.up.arrow.down") {
                        Picker("Sort", selection: $expenseSortDescriptors){
                            Text("Sort by time")
                                .tag([
                                    SortDescriptor(\Expense.createdDate, order: .reverse),
                                    SortDescriptor(\Expense.title)
                                ])
                            Text("Sort by name")
                                .tag([
                                    SortDescriptor(\Expense.title),
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
                switch selectedSegment {
                case .expense:
                    AddExpenseView()
                case .budget:
                    AddBudgetView()
                }
            }
        }
    }
    
    #if DEBUG
    func addMockData() {
        
        switch selectedSegment {
        case .expense:
            let expenses: [Expense] = Bundle.main.decode("expense.mock.json")
            
            for expense in expenses {
                let date: Date = .now.addingTimeInterval(86400 * expenseDayCounter)
                expense.date = date
                modelContext.insert(expense)
            }
            
            expenseDayCounter = expenseDayCounter - 1
            isExpensesEmpty = false
        case .budget:
            let budgets: [Budget] = Bundle.main.decode("budget.mock.json")
            
            for budget in budgets {
                let date: Date = .now.addingTimeInterval(86400 * budgetDayCounter)
                budget.date = date
                modelContext.insert(budget)
            }
            
            budgetDayCounter = budgetDayCounter - 1
            isBudgetsEmpty = false
        }
    }
    
    func deleteAlldata() {
        do {
            switch selectedSegment {
            case .expense:
                let descriptor = FetchDescriptor<Expense>()
                let toDeleteData = try modelContext.fetch(descriptor)
                
                for expense in toDeleteData {
                    modelContext.delete(expense)
                }
                
                isExpensesEmpty = true
                budgetDayCounter = 0
            case .budget:
                let descriptor = FetchDescriptor<Budget>()
                let toDeleteData = try modelContext.fetch(descriptor)
                
                for budget in toDeleteData {
                    modelContext.delete(budget)
                }
                
                isBudgetsEmpty = true
                budgetDayCounter = 0
            }
        } catch {
            fatalError("Something went wrong.")
        }
    }
    #endif
}

#Preview {
    HomeView()
}

