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

    @State private var selectedSegment: HomeViewSegments = .budget
    
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
    
    func processStartOfTheWeek() {
        if expenseFirstDayOfWeek == "" {
            let calendar = Calendar.current
            let isoFormatter = ISO8601DateFormatter()
            
            let weekday = calendar.component(.weekday, from: .today)
            let daysToMonday = (weekday == 1 ? -6 : 2 - weekday)
            
            let monday = calendar.date(byAdding: .day, value: daysToMonday, to: .today)!.startOfDay
            
            let dateString = isoFormatter.string(from: monday)
            
            expenseFirstDayOfWeek = dateString
        } else {
            let calendar = Calendar.current
            let isoFormatter = ISO8601DateFormatter()
            let date = isoFormatter.date(from: expenseFirstDayOfWeek)!.startOfDay
            
            let components = calendar.dateComponents([.day], from: date, to: .today)
            
            if let daysAhead = components.day, daysAhead >= 7 {
                totalWeekExpenses = "0.0"
                isWeekExpenseEmpty = true
                
                let dateString = isoFormatter.string(from: .today)
                expenseFirstDayOfWeek = dateString
            }
        }
        
        if incomeFirstDayOfWeek == "" {
            let calendar = Calendar.current
            let isoFormatter = ISO8601DateFormatter()
            
            let weekday = calendar.component(.weekday, from: .today)
            let daysToMonday = (weekday == 1 ? -6 : 2 - weekday)
            
            let monday = calendar.date(byAdding: .day, value: daysToMonday, to: .today)!.startOfDay
            
            let dateString = isoFormatter.string(from: monday)
            
            incomeFirstDayOfWeek = dateString
        } else {
            let calendar = Calendar.current
            let isoFormatter = ISO8601DateFormatter()
            let date = isoFormatter.date(from: incomeFirstDayOfWeek)!.startOfDay
            
            let components = calendar.dateComponents([.day], from: date, to: .today)
            
            if let daysAhead = components.day, daysAhead >= 7 {
                totalWeekIncomes = "0.0"
                isWeekExpenseEmpty = true
                
                let dateString = isoFormatter.string(from: .today)
                incomeFirstDayOfWeek = dateString
            }
        }
    }
    #if DEBUG
    func addMockData() {
        
        switch selectedSegment {
        case .expense:
            let expenses: [Expense] = Bundle.main.decode("expense.mock.json")
            
            let shuffledExpenses = expenses.shuffled().prefix(Int.random(in: 1...12))
            
            for expense in shuffledExpenses {
                let date: Date = .today.addingTimeInterval(86400 * expenseDayCounter)
                expense.setMockDate(at: date)
                
                do {
                    let fetchDescriptor = FetchDescriptor<Budget>()
                    let fetchBudgets = try modelContext.fetch(fetchDescriptor)
                    
                    if !fetchBudgets.isEmpty, let budget = fetchBudgets.randomElement() {
                        expense.setMockBudget(at: budget)
                        expense.save(modelContext: modelContext)
                    }
                    
                } catch {
                    fatalError("Error deleting budget")
                }
            }
            
            expenseDayCounter -= 1
        case .income:
            let incomes: [Income] = Bundle.main.decode("income.mock.json")
            
            let shuffledIncomes = incomes.shuffled().prefix(Int.random(in: 1...12))
            
            for income in shuffledIncomes {
                let date: Date = .today.addingTimeInterval(86400 * incomeDayCounter)
                income.setMockDate(at: date)
                
                do {
                    let fetchDescriptor = FetchDescriptor<Budget>()
                    let fetchBudgets = try modelContext.fetch(fetchDescriptor)
                    
                    if !fetchBudgets.isEmpty, let budget = fetchBudgets.first {
                        income.setMockBudget(at: budget)
                        income.save(modelContext: modelContext)
                    }
                    
                } catch {
                    fatalError("Error deleting budget")
                }
            }
            incomeDayCounter -= 1
        case .budget:
            let budgets: [Budget] = Bundle.main.decode("budget.mock.json")
            
            for budget in budgets {
                let date: Date = .today.addingTimeInterval(86400 * budgetDayCounter)
                budget.setMockDate(at: date)
                budget.save(incomes: [], expenses: [], modelContext: modelContext)
            }
            budgetDayCounter -= 1
        #if DEBUG
        case .logs:
            print("N/A")
        #endif
        }
    }
    
    func deleteAlldata() {
        do {
            switch selectedSegment {
            case .expense:
                let descriptor = FetchDescriptor<Expense>()
                let toDeleteData = try modelContext.fetch(descriptor)
                toDeleteData.delete(modelContext: modelContext)
                totalWeekExpenses = "0.0"
                expenseDayCounter += 0
            case .income:
                let descriptor = FetchDescriptor<Income>()
                let toDeleteData = try modelContext.fetch(descriptor)
                toDeleteData.delete(modelContext: modelContext)
                totalWeekIncomes = "0.0"
                incomeDayCounter = 0
            case .budget:
                let descriptor = FetchDescriptor<Budget>()
                let toDeleteData = try modelContext.fetch(descriptor)
                toDeleteData.delete(modelContext: modelContext)
                totalBudget = "0.0"
                budgetDayCounter += 0
            #if DEBUG
            case .logs:
                print("N/A")
            #endif
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

