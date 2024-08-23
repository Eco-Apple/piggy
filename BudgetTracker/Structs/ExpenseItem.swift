//
//  ExpenseItem.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/10/24.
//

import Foundation

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    var amount: Double
    var reasonForExpense: String
    var createdDate: Date
    var updateDate: Date
}
