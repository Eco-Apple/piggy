//
//  Expense.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/25/24.
//

import Foundation
import SwiftData

@Model
class Expense {
    var name: String
    var desc: String
    var amount: Decimal
    var createdDate: Date
    var updateDate: Date
    
    init(name: String, desc: String, amount: Decimal, createdDate: Date, updateDate: Date) {
        self.name = name
        self.desc = desc
        self.amount = amount
        self.createdDate = createdDate
        self.updateDate = updateDate
    }
}
