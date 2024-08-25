//
//  ExpenseItem.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/10/24.
//

import Foundation

struct ExpenseItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var description: String
    var amount: Decimal
    var createdDate: Date
    var updateDate: Date
}
