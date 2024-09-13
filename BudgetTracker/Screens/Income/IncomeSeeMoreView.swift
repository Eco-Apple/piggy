//
//  BudgetSeeMoreView.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 9/7/24.
//

import SwiftUI

struct IncomeSeeMoreView: View {
    var date: Date
    var incomes: [Income]
    
    var body: some View {
        List {
            ForEach(incomes) { income in
                NavigationLink(value: NavigationRoute.income(.detail(income))) {
                    IncomeItemView(income: income)
                }
            }
        }
        .navigationTitle(date.format(.dateOnly, descriptive: true))
    }
}

#Preview {
    IncomeSeeMoreView(date: .now, incomes: [Income.previewItem])
}
