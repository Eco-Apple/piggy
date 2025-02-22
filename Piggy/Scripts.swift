//
//  Scripts.swift
//  Piggy
//
//  Created by Jerico Villaraza on 2/6/25.
//

import SwiftData
import Foundation

struct Scripts {
    static func run(modelContext: ModelContext) {
        let previousAppVersion = AppVersionHelper.previous
        let currentAppVersion = AppVersionHelper.current
        
        if previousAppVersion != currentAppVersion {
            
            if previousAppVersion != "1.0.21" {
                fixWeekExpenseOverall(modelContext)
                fixWeekIncomeOverall(modelContext)
            }
            
            AppVersionHelper.update()
        }
    }
    
    
    static func fixWeekExpenseOverall(_ modelContext: ModelContext) {
        do {
            let lastMonday = Date.getPreviousStartDayMonday
            
            let fetchDescriptor = FetchDescriptor<Expense>(
                predicate: #Predicate { $0.date > lastMonday }
            )
            
            let expenses = try modelContext.fetch(fetchDescriptor)
            
            var totalWeekExpense: Decimal = 0.0
            
            for expense in expenses {
                totalWeekExpense += expense.amount
            }
            
            let totalWeekExpenseString: String = "\(totalWeekExpense)"

            UserDefaults.standard.set(totalWeekExpenseString, forKey: "totalWeekExpenses")
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    static func fixWeekIncomeOverall(_ modelContext: ModelContext) {
        do {
            let lastMonday = Date.getPreviousStartDayMonday
            
            let fetchDescriptor = FetchDescriptor<Income>(
                predicate: #Predicate { $0.date > lastMonday }
            )
            
            let expenses = try modelContext.fetch(fetchDescriptor)
            
            var totalWeekExpense: Decimal = 0.0
            
            for expense in expenses {
                totalWeekExpense += expense.amount
            }
            
            let totalWeekExpenseString: String = "\(totalWeekExpense)"

            UserDefaults.standard.set(totalWeekExpenseString, forKey: "totalWeekIncomes")
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}
