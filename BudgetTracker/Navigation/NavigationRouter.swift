//
//  NavigationRouter.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/31/24.
//

import Foundation
import SwiftUI

@Observable
class NavigationRouter {
    var path = NavigationPath()
    
    @ViewBuilder
    func destination(for route: NavigationRoute) -> some View {
        switch route {
        case .expense(let route):
            handleExpenseRoutes(route)
        }
    }
    
    @ViewBuilder
    private func handleExpenseRoutes(_ route: NavigationRoute.ExpenseRoute) -> some View {
        switch route {
        case .list:
            Text("")
        case .create:
            Text("Test")
        case .detail(let expense):
            ExpenseView(expense)
        case .seeMore(let date, let expenses):
            SeeMoreView(date: date, expenses: expenses)
        }
    }
}
