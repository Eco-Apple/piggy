//
//  NavigationRoute.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/31/24.
//

import Foundation

enum NavigationRoute: Hashable {
    case expense(ExpenseRoute)
    
    enum ExpenseRoute: Hashable {
        case list
        case create
        case detail(Expense)
        case seeMore(Date, [Expense])
    }
}
