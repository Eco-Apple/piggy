//
//  Enums.swift
//  Piggy
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
    
    #if DEBUG
    case logs
    #endif
    
    var title: String {
        switch self {
        case .expense: return "Expense"
        case .income: return "Income"
        case .budget: return "Budget"
            
        #if DEBUG
        case .logs: return "Logs"
        #endif
        }
    }
}
