//
//  NavigationRoute.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/31/24.
//

import Foundation

enum NavigationRoute: Hashable {
    case expense(ExpenseRoute)
    case income(IncomeRoute)
    case budget(BudgetRoute)
    
    enum ExpenseRoute: Hashable {
        case detail(Expense)
        case seeMore(title: String, expenses: [Expense], canAdd: Bool = false, passedBudget: Budget? = nil)
    }
    
    enum IncomeRoute: Hashable {
        case detail(Income)
        case seeMore(title: String, incomes: [Income], canAdd: Bool = false, passedBudget: Budget? = nil)
    }
    
    enum BudgetRoute: Hashable {
        case detail(Budget)
        case seeMore(Date, [Budget])
    }
}
