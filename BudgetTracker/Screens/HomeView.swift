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
    @AppStorage("isIncomesEmpty") var isIncomesEmpty = true
    @AppStorage("isBudgetsEmpty") var isBudgetsEmpty = true
    
    @AppStorage("totalWeekExpenses") var totalWeekExpenses = "0.0"
    @AppStorage("totalWeekBudgets") var totalWeekBudgets = "0.0"
    @AppStorage("totalWeekIncomes") var totalWeekIncomes = "0.0"
    
    @State var expenseDayCounter: Double = 0
    @State var incomeDayCounter: Double = 0
    @State var budgetDayCounter: Double = 0
    #endif
    
    @State private var isAddViewPresented = false
    
    @State private var expenseSortDescriptors: [SortDescriptor<Expense>] = [
        SortDescriptor(\Expense.createdDate, order: .reverse),
    ]
    
    @State private var incomesSortDescriptors: [SortDescriptor<Income>] = [
        SortDescriptor(\Income.createdDate, order: .reverse),
    ]
    
    @State private var budgetsSortDescriptors: [SortDescriptor<Budget>] = [
        SortDescriptor(\Budget.createdDate, order: .reverse),
    ]

    @State private var selectedSegment: HomeViewSegments = .budget
    
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
                }
                
                Picker("Select a segment", selection: $selectedSegment) {
                    Text("Budget").tag(HomeViewSegments.budget)
                    Text("Expenses").tag(HomeViewSegments.expense)
                    Text("Income").tag(HomeViewSegments.income)
                 }
                 .pickerStyle(SegmentedPickerStyle())
                 .frame(width: 250)
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
                            Picker("Sort", selection: $expenseSortDescriptors){
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
                            Picker("Sort", selection: $expenseSortDescriptors){
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
                case .income:
                    AddIncomeView()
                case .budget:
                    AddBudgetView()
                }
            }
            #if DEBUG
            .onAppear {
                    do {
                        let fetchBudget = try modelContext.fetch(FetchDescriptor<Budget>())
                        let fetchExpense = try modelContext.fetch(FetchDescriptor<Expense>())
                        let fetchIncome = try modelContext.fetch(FetchDescriptor<Income>())
                                                
                        print("Budget: \(fetchBudget.count)")
                        print("Expense: \(fetchExpense.count)")
                        print("Income: \(fetchIncome.count)")
                        
                        print("isBudgetsEmpty: \(isBudgetsEmpty)")
                        print("isExpensesEmpty: \(isExpensesEmpty)")
                        print("isIncomesEmpty: \(isIncomesEmpty)")
                        
                        print("totalWeekBudgets: \(totalWeekBudgets)")
                        print("totalWeekExpenses: \(totalWeekExpenses)")
                        print("totalWeekIncomes: \(totalWeekIncomes)")
                    } catch {
                        fatalError("Cannot fetch data")
                    }
            }
            #endif
        }
    }
    
    #if DEBUG
    func addMockData() {
        
        switch selectedSegment {
        case .expense:
            let expenses: [Expense] = Bundle.main.decode("expense.mock.json")
            var totalExpense: Decimal = 0.0
            
            for expense in expenses {
                let date: Date = .now.addingTimeInterval(86400 * expenseDayCounter)
                expense.date = date
                totalExpense = totalExpense + expense.amount
                modelContext.insert(expense)
            }
            
            totalWeekExpenses = totalWeekExpenses.arithmeticOperation(of: totalExpense, .add)!
            
            expenseDayCounter = expenseDayCounter - 1
            isExpensesEmpty = false
        case .income:
            let incomes: [Income] = Bundle.main.decode("income.mock.json")
            var totalIncome: Decimal = 0.0
            
            for income in incomes {
                let date: Date = .now.addingTimeInterval(86400 * incomeDayCounter)
                income.date = date
                totalIncome = totalIncome + income.amount
                modelContext.insert(income)
            }
            
            totalWeekIncomes = totalWeekIncomes.arithmeticOperation(of: totalIncome, .add)!
            
            incomeDayCounter = incomeDayCounter - 1
            isIncomesEmpty = false
        case .budget:
            let budgets: [Budget] = Bundle.main.decode("budget.mock.json")
            var totalBudget: Decimal = 0.0
            
            for budget in budgets {
                let date: Date = .now.addingTimeInterval(86400 * budgetDayCounter)
                budget.date = date
//                totalBudget = totalBudget + budget.estimatedAmount TODO: Total budgets
                modelContext.insert(budget)
            }
            
            totalWeekBudgets = totalWeekBudgets.arithmeticOperation(of: totalBudget, .add)!
            
            budgetDayCounter = budgetDayCounter - 1
            isBudgetsEmpty = false
            break
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
                
                totalWeekExpenses = "0.0"
                isExpensesEmpty = true
                expenseDayCounter = 0
            case .income:
                let descriptor = FetchDescriptor<Income>()
                let toDeleteData = try modelContext.fetch(descriptor)
                
                for income in toDeleteData {
                    modelContext.delete(income)
                }
                
                totalWeekIncomes = "0.0"
                isIncomesEmpty = true
                incomeDayCounter = 0
            case .budget:
                let descriptor = FetchDescriptor<Budget>()
                let toDeleteData = try modelContext.fetch(descriptor)
                
                for budget in toDeleteData {
                    modelContext.delete(budget)
                }
                
                totalWeekBudgets = "0.0"
                isBudgetsEmpty = true
                budgetDayCounter = 0
                break
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

