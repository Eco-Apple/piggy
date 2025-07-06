//
//  HomeView+Debug.swift
//  Piggy
//
//  Created by Jerico Villaraza on 7/6/25.
//

import SwiftUI
import SwiftData

extension HomeView {
    #if DEBUG
    func addMockData() {
        switch selectedSegment {
        case .expense:
            guard let expenses: [Expense] = Bundle.main.decode("expense.mock.json") else { return }
            
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
                    debugPrint("Error deleting budget")
                }
            }
            
            expenseDayCounter -= 1
        case .income:
            guard let incomes: [Income] = Bundle.main.decode("income.mock.json") else { return }
            
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
                    debugPrint("Error deleting budget")
                }
            }
            incomeDayCounter -= 1
        case .budget:
            guard let budgets: [Budget] = Bundle.main.decode("budget.mock.json") else { return }
            
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
            debugPrint("Something went wrong.")
        }
    }
    #endif
}
