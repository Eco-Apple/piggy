//
//  BudgetSeeMoreView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 9/7/24.
//

import SwiftUI

struct BudgetSeeMoreView: View {
    var date: Date
    var budgets: [Budget]
    
    var body: some View {
        List {
            ForEach(budgets) { budget in
                NavigationLink(value: NavigationRoute.budget(.detail(budget))) {
                    BudgetListItemView(budget: budget)
                }
            }
        }
        .navigationTitle(date.format(.dateOnly, descriptive: true))
    }
}

#Preview {
    BudgetSeeMoreView(date: .now, budgets: [Budget.previewItem])
}
