//
//  Expenses.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/10/24.
//

import Foundation

@Observable
class Expenses {
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "expenses")
            }
        }
    }
    
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "expenses") {
            if let decode = try? JSONDecoder().decode([ExpenseItem].self, from: data) {
                items = decode
                
                return
            }
        }
        
        items = []
    }
}
