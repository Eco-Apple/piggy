//
//  Expense.swift
//  Piggy
//
//  Created by Jerico Villaraza on 8/25/24.
//

import Foundation
import SwiftData

@Model
class Expense: Codable {
    
    enum CodingKeys: String, CodingKey {
        case title
        case note
        case amount
        case date
        case createdDate
        case updatedDate
        case isTimeEnabled
        case budget
    }
    
    private(set) var title: String
    private(set) var note: String
    private(set) var amount: Decimal
    private(set) var date: Date
    private(set) var createdDate: Date
    private(set) var updatedDate: Date
    
    private(set) var isTimeEnabled: Bool
    
    private(set) var budget: Budget
    
    init(title: String, note: String, amount: Decimal, date: Date, createdDate: Date, updateDate: Date, isTimeEnabled: Bool, budget: Budget) {
        self.title = title
        self.note = note
        self.amount = amount
        self.date = date
        self.createdDate = createdDate
        self.updatedDate = updateDate
        self.isTimeEnabled = isTimeEnabled
        self.budget = budget
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        note = try container.decode(String.self, forKey: .note)
        amount = try container.decode(Decimal.self, forKey: .amount)
        date = try container.decode(Date.self, forKey: .date)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        updatedDate = try container.decode(Date.self, forKey: .updatedDate)
        isTimeEnabled = try container.decode(Bool.self, forKey: .isTimeEnabled)
        budget = try container.decode(Budget.self, forKey: .budget)
    }
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(note, forKey: .note)
        try container.encode(amount, forKey: .amount)
        try container.encode(date, forKey: .date)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(updatedDate, forKey: .updatedDate)
        try container.encode(isTimeEnabled, forKey: .isTimeEnabled)
        try container.encode(budget, forKey: .budget)
    }
}

extension Expense {
    static var previewItem: Expense {
        Expense(title: "Shopping", note: "Monthly shopping", amount: 100.0, date: Date.distantPast, createdDate: .today, updateDate: .today, isTimeEnabled: false, budget: .previewItem)
    }
    
    func save(modelContext: ModelContext, budget: Budget? = nil) {
        
        var totalWeekExpenses: String {
            get {
                UserDefaults.standard.string(forKey: "totalWeekExpenses") ?? "0.0"
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "totalWeekExpenses")
            }
        }
        
        var isWeekExpenseEmpty: Bool {
            get {
                UserDefaults.standard.bool(forKey: "isWeekExpenseEmpty")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "isWeekExpenseEmpty")
            }
        }
        
        if let budget {
            self.budget = budget
        }
        
        if Date.getPreviousStartDayMonday <= self.date {
            totalWeekExpenses = totalWeekExpenses.arithmeticOperation(of: amount, .add)!
        }
        
        modelContext.insert(self)
        try? modelContext.save(); #warning ("Current bug of swift data: see https://www.hackingwithswift.com/quick-start/swiftdata/how-to-save-a-swiftdata-object")
        
        self.budget.addOrSub(amount: amount, operation: .sub, expense: self)
        isWeekExpenseEmpty = false
    }
    
    func edit(_ modelContext: ModelContext, title: String, note: String, amount: Decimal, date: Date, isTimeEnabled: Bool, budget: Budget){
        let oldAmount = self.amount
        
        self.title = title
        self.note = note
        self.amount = amount
        self.date = date
        self.isTimeEnabled = isTimeEnabled
        self.updatedDate = .today
        
        
        var totalWeekExpenses: String {
            get {
                UserDefaults.standard.string(forKey: "totalWeekExpenses") ?? "0.0"
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "totalWeekExpenses")
            }
        }
        
        if Date.getPreviousStartDayMonday <= self.date {
            totalWeekExpenses = totalWeekExpenses.arithmeticOperation(of: oldAmount, .sub)!
            totalWeekExpenses = totalWeekExpenses.arithmeticOperation(of: amount, .add)!
        }
        
        self.setBudget(budget, oldAmount: oldAmount)
    }
    
    private func setBudget(_ newBudget: Budget, oldAmount: Decimal) {
        
        var totalBudget: String {
            get {
                UserDefaults.standard.string(forKey: "totalBudget") ?? "0.0"
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "totalBudget")
            }
        }
        
        if budget == newBudget {
            budget.decreaseTotalExpense(to: oldAmount)
            budget.increaseTotalExpense(to: amount)
            
            totalBudget = totalBudget.arithmeticOperation(of: oldAmount, .add)!
            totalBudget = totalBudget.arithmeticOperation(of: amount, .sub)!
        } else {
            budget.decreaseTotalExpense(to: oldAmount)
            newBudget.increaseTotalExpense(to: amount)
            
            budget.removeExpense(of: self)
            newBudget.addExpense(of: self)
            
            budget = newBudget
            totalBudget = totalBudget.arithmeticOperation(of: oldAmount, .add)!
            totalBudget = totalBudget.arithmeticOperation(of: amount, .sub)!
        }
    }
    
    #if DEBUG
    func setMockDate(at date: Date) {
        self.date = date
    }
    
    func setMockBudget(at budget: Budget) {
        self.budget = budget
    }
    #endif

}


extension [Expense] {
    
    func delete(modelContext: ModelContext) {
        
        var totalWeekExpenses: String {
            get {
                UserDefaults.standard.string(forKey: "totalWeekExpenses") ?? "0.0"
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "totalWeekExpenses")
            }
        }
        
        
        var isWeekExpenseEmpty: Bool {
            get {
                UserDefaults.standard.bool(forKey: "isWeekExpenseEmpty")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "isWeekExpenseEmpty")
            }
        }
        
        var totalWeekDeletedItems: Decimal = 0.0
        
        for item in self {
            if Date.getPreviousStartDayMonday <= item.date {
                totalWeekDeletedItems = totalWeekDeletedItems + item.amount
            }
            
            item.budget.itemDeletedFor(expense: item, modelContext: modelContext)
            
            modelContext.delete(item)
            try? modelContext.save(); #warning ("Current bug of swift data: see https://www.hackingwithswift.com/quick-start/swiftdata/how-to-save-a-swiftdata-object")
        }
        
        totalWeekExpenses = totalWeekExpenses.arithmeticOperation(of: totalWeekDeletedItems, .sub)!
        
        do {
            let fetchDescriptor = FetchDescriptor<Expense>()
            let fetchExpenses = try modelContext.fetch(fetchDescriptor)
            
            if fetchExpenses.isEmpty {
                isWeekExpenseEmpty = true
            }
            
        } catch {
            fatalError("Error deleting expenses")
        }
    }

}
