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
        case .income(let route):
            handleIncomeRoutes(route)
        case .budget(let route):
            handleBudgetRoutes(route)
        }
    }
    
    @ViewBuilder
    private func handleExpenseRoutes(_ route: NavigationRoute.ExpenseRoute) -> some View {
        switch route {
        case .detail(let expense):
            ExpenseDetailView(expense)
        case .seeMore(let date, let expenses):
            ExpenseSeeMoreView(date: date, expenses: expenses)
        }
    }
    
    @ViewBuilder
    private func handleIncomeRoutes(_ route: NavigationRoute.IncomeRoute) -> some View {
        switch route {
        case .detail(let income):
            IncomeDetailView(income)
        case .seeMore(let date, let incomes):
            IncomeSeeMoreView(date: date, incomes: incomes)
        }
    }
    
    
    @ViewBuilder
    private func handleBudgetRoutes(_ route: NavigationRoute.BudgetRoute) -> some View {
        switch route {
        case .detail(let budget):
            BudgetDetailView(budget)
        case .seeMore(let date, let budgets):
            BudgetSeeMoreView(date: date, budgets: budgets)
        }
    }


}
