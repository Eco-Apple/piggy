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
    
    enum ExpenseRoute: Hashable {
        case detail(Expense)
        case seeMore(Date, [Expense])
    }
    
    enum IncomeRoute: Hashable {
        case detail(Income)
        case seeMore(Date, [Income])
    }
}
