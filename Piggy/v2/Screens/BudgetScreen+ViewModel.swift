//
//  BudgetScreen+ViewModel.swift
//  Piggy
//
//  Created by Jerico Villaraza on 8/31/25.
//

import SwiftUI

extension BudgetScreen {
    @Observable
    class ViewModel {
        let items: [BudgetItem] = [
            .init(title: "Income", amount: 100, icon: "creditcard", type: .income),
            .init(title: "Essentials", amount: 200, icon: "basket", type: .essential),
            .init(title: "Non-Essentials", amount: 300, icon: "gamecontroller", type: .nonEssential),
            .init(title: "Savings", amount: 400, icon: "wallet.bifold", type: .savings),
            .init(title: "Total Expenses", amount: 500, icon: "cart", type: .totalExpenses),
            .init(title: "Extra", amount: 600, icon: "heart", type: .extra)
        ]
        
        let columns = [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]
    }
}
