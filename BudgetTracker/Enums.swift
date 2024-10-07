//
//  Enums.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 9/7/24.
//

import Foundation

enum DateStyle {
    case dateOnly
    case timeOnly
    case dateAndTime
}

enum HomeViewSegments {
    case expense, income, budget
    
    var title: String {
        switch self {
        case .expense: return "Expense"
        case .income: return "Income"
        case .budget: return "Budget"
        }
    }
}
