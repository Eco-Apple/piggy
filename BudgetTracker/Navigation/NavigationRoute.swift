//
//  NavigationRoute.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/31/24.
//

import Foundation

enum NavigationRoute: Hashable {
    case expense(ExpenseRoute)
    case budget(BudgetRoute)
    
    enum ExpenseRoute: Hashable {
        case detail(Expense)
        case seeMore(Date, [Expense])
    }
    
    enum BudgetRoute: Hashable {
        case detail(Budget)
        case seeMore(Date, [Budget])
    }
}
