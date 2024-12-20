//
//  NavigationRouter.swift
//  Piggy
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
        case .seeMore(let title, let expenses, let canAdd, let passedBudget):
            ExpenseSeeMoreView(title: title, expenses: expenses, canAdd: canAdd, passedBudget: passedBudget)
        }
    }
    
    @ViewBuilder
    private func handleIncomeRoutes(_ route: NavigationRoute.IncomeRoute) -> some View {
        switch route {
        case .detail(let income):
            IncomeDetailView(income)
        case .seeMore(let title, let incomes, let canAdd, let passedBudget):
            IncomeSeeMoreView(title: title, incomes: incomes, canAdd: canAdd, passedBudget: passedBudget)
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
