//
//  structs.swift
//  Piggy
//
//  Created by Jerico Villaraza on 1/3/26.
//

import SwiftUI

struct BudgetItem: Identifiable {
    let id = UUID()
    let title: String
    var amount: Decimal
    let icon: String
    let type: BudgetType
    
    static var example: BudgetItem {
        BudgetItem(title: "Example", amount: 100, icon: "house", type: .income)
    }
}

