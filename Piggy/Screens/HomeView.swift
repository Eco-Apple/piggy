//
//  ContentView.swift
//  Piggy
//
//  Created by Jerico Villaraza on 8/1/24.
//

import StoreKit
import SwiftData
import SwiftUI

struct HomeView: View {
    
    @Environment(\.modelContext) var modelContext
    
    #if DEBUG
    @AppStorage("isBudgetsEmpty") var isBudgetsEmpty = true
    @AppStorage("totalBudget") var totalBudget = "0.0"
    @State var expenseDayCounter: Double = 0
    @State var incomeDayCounter: Double = 0
    @State var budgetDayCounter: Double = 0
    #endif
    
    @AppStorage("isWeekExpenseEmpty") var isWeekExpenseEmpty = true
    @AppStorage("totalWeekExpenses") var totalWeekExpenses = "0.0"
    
    @AppStorage("isWeekIncomeEmpty") var isWeekIncomeEmpty = true
    @AppStorage("totalWeekIncomes") var totalWeekIncomes = "0.0"
    
    @AppStorage("expenseFirstDayOfWeek") var expenseFirstDayOfWeek = ""
    @AppStorage("incomeFirstDayOfWeek") var incomeFirstDayOfWeek = ""
    
    
    @State private var isAddViewPresented = false
    
    @State private var expenseSortDescriptors: [SortDescriptor<Expense>] = [
        SortDescriptor(\Expense.date, order: .reverse),
        SortDescriptor(\Expense.title)
    ]
    
    @State private var incomesSortDescriptors: [SortDescriptor<Income>] = [
        SortDescriptor(\Income.date, order: .reverse),
        SortDescriptor(\Income.title)
    ]
    
    @State private var budgetsSortDescriptors: [SortDescriptor<Budget>] = [
        SortDescriptor(\Budget.date, order: .reverse),
        SortDescriptor(\Budget.title)
    ]
    
    @State var selectedSegment: HomeViewSegments = .budget
    
    init() {
        processStartOfTheWeek()
    }
    
    var body: some View {
        Navigation {
            VStack(alignment: .leading) {
                switch selectedSegment {
                case .expense:
                    ExpenseListView(sortDescriptors: expenseSortDescriptors)
                case .income:
                    IncomeListView(sortDescriptors: incomesSortDescriptors)
                case .budget:
                    BudgetListView(sortDescriptors: budgetsSortDescriptors)
                #if DEBUG
                case .logs:
                    LogsView()
                #endif
                }
                
                Picker("Select a segment", selection: $selectedSegment) {
                    Text("Budget").tag(HomeViewSegments.budget)
                    Text("Expense").tag(HomeViewSegments.expense)
                    Text("Income").tag(HomeViewSegments.income)
                    #if DEBUG
                    Text("Logs").tag(HomeViewSegments.logs)
                    #endif
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 250)
                .padding()
            }
            .navigationTitle(selectedSegment.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitleDisplayMode(.inline)
            .scrollBounceBehavior(.basedOnSize)
            .toolbar {
                
                #if DEBUG
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("add mock data", systemImage: "flame", action: addMockData)
                    Button("delete all data", systemImage: "trash", action: deleteAlldata)
                }
                #endif
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    switch selectedSegment {
                    case .expense:
                        Menu("Sort", systemImage: "arrow.up.arrow.down") {
                            Picker("Sort", selection: $expenseSortDescriptors){
                                Text("Sort by time")
                                    .tag([
                                        SortDescriptor(\Expense.date, order: .reverse),
                                        SortDescriptor(\Expense.title)
                                    ])
                                Text("Sort by name")
                                    .tag([
                                        SortDescriptor(\Expense.title),
                                        SortDescriptor(\Expense.date, order: .reverse)
                                    ])
                            }
                        }
                    case .income:
                        Menu("Sort", systemImage: "arrow.up.arrow.down") {
                            Picker("Sort", selection: $incomesSortDescriptors){
                                Text("Sort by time")
                                    .tag([
                                        SortDescriptor(\Income.date, order: .reverse),
                                        SortDescriptor(\Income.title)
                                    ])
                                Text("Sort by name")
                                    .tag([
                                        SortDescriptor(\Income.title),
                                        SortDescriptor(\Income.date, order: .reverse)
                                    ])
                            }
                        }
                    case .budget:
                        Menu("Sort", systemImage: "arrow.up.arrow.down") {
                            Picker("Sort", selection: $budgetsSortDescriptors){
                                Text("Sort by time")
                                    .tag([
                                        SortDescriptor(\Budget.date, order: .reverse),
                                        SortDescriptor(\Budget.title)
                                    ])
                                Text("Sort by name")
                                    .tag([
                                        SortDescriptor(\Budget.title),
                                        SortDescriptor(\Budget.date, order: .reverse)
                                    ])
                            }
                        }
                    #if DEBUG
                    case .logs:
                        EmptyView()
                    #endif
                    }
                    
                    
                    Button{
                        isAddViewPresented = true
                    } label: {
                        Label("Add Button", systemImage: "plus")
                            .foregroundStyle(Color("Accent"))
                    }
                }
            }
            .sheet(isPresented: $isAddViewPresented) {
                switch selectedSegment {
                case .expense:
                    AddExpenseView()
                case .income:
                    AddIncomeView()
                case .budget:
                    AddBudgetView()
                #if DEBUG
                case .logs:
                    EmptyView()
                #endif
                }
            }
        }
        .onAppear {
            Scripts.run(modelContext: modelContext)
        }
    }
    
}

#Preview {
    HomeView()
}

