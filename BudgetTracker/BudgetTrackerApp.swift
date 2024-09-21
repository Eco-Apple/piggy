//
//  BudgetTrackerApp.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/1/24.
//

import SwiftData
import SwiftUI

@main
struct IncomeTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: [Expense.self, Income.self, Budget.self])
    }
}
