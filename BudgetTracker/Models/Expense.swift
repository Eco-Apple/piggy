//
//  Expense.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/25/24.
//

import Foundation
import SwiftData

@Model
class Expense: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case note
        case amount
        case date
        case createdDate
        case updatedDate
        case isTimeEnabled
        case budget
    }
    
    private(set) var id: UUID
    private(set) var title: String
    private(set) var note: String
    private(set) var amount: Decimal
    private(set) var date: Date?
    private(set) var createdDate: Date
    private(set) var updatedDate: Date
    
    private(set) var isTimeEnabled: Bool
    
    private(set) var budget: Budget
    
    init(title: String, note: String, amount: Decimal, date: Date?, createdDate: Date, updateDate: Date, isTimeEnabled: Bool, budget: Budget) {
        self.id = UUID()
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
        id = try container.decode(UUID.self, forKey: .id)
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
        try container.encode(id, forKey: .id)
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
        Expense(title: "Shopping", note: "Monthly shopping", amount: 100.0, date: Date.distantPast, createdDate: .now, updateDate: .now, isTimeEnabled: false, budget: .previewItem)
    }
    
    func save(modelContext: ModelContext) {
        var totalWeekExpenses: String {
            get {
                UserDefaults.standard.string(forKey: "totalWeekExpenses") ?? "0.0"
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "totalWeekExpenses")
            }
        }
        
        var isExpensesEmpty: Bool {
            get {
                UserDefaults.standard.bool(forKey: "isExpensesEmpty")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "isExpensesEmpty")
            }
        }
        
        totalWeekExpenses = totalWeekExpenses.arithmeticOperation(of: self.amount, .add)!
        modelContext.insert(self)
        self.budget.addOrSub(amount: self.amount, operation: .sub, expense: self)
        isExpensesEmpty = false
    }
    
    func edit(title: String, note: String, amount: Decimal, date: Date, isTimeEnabled: Bool, budget: Budget){
        let oldAmount = self.amount
        
        self.title = title
        self.note = note
        self.amount = amount
        self.date = date
        self.isTimeEnabled = isTimeEnabled
        self.updatedDate = .now
        
        
        var totalWeekExpenses: String {
            get {
                UserDefaults.standard.string(forKey: "totalWeekExpenses") ?? "0.0"
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "totalWeekExpenses")
            }
        }
        
        totalWeekExpenses = totalWeekExpenses.arithmeticOperation(of: oldAmount, .sub)!
        totalWeekExpenses = totalWeekExpenses.arithmeticOperation(of: amount, .add)!
        
        self.setBudget(budget, oldAmount: oldAmount)
    }
    
    private func setBudget(_ newBudget: Budget, oldAmount: Decimal) {
        
        var totalWeekBudgets: String {
            get {
                UserDefaults.standard.string(forKey: "totalWeekBudgets") ?? "0.0"
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "totalWeekBudgets")
            }
        }
        
        if budget == newBudget {
            budget.decreaseTotalExpense(to: oldAmount)
            budget.increaseTotalExpense(to: amount)
            
            totalWeekBudgets = totalWeekBudgets.arithmeticOperation(of: oldAmount, .add)!; #warning ("This will break if user edit budget previous week")
            totalWeekBudgets = totalWeekBudgets.arithmeticOperation(of: amount, .sub)!; #warning ("This will break if user edit budget previous week")
        } else {
            budget.decreaseTotalExpense(to: oldAmount)
            newBudget.increaseTotalExpense(to: amount)
            
            budget.removeExpense(of: self)
            newBudget.addExpense(of: self)
            
            totalWeekBudgets = totalWeekBudgets.arithmeticOperation(of: oldAmount, .add)!; #warning ("This will break if user edit budget previous week")
            totalWeekBudgets = totalWeekBudgets.arithmeticOperation(of: amount, .sub)!; #warning ("This will break if user edit budget previous week")
        }
    }

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
        
        
        var isExpensesEmpty: Bool {
            get {
                UserDefaults.standard.bool(forKey: "isExpensesEmpty")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "isExpensesEmpty")
            }
        }
        
        var totalDeletedItems: Decimal = 0.0
        
        for item in self {
            if Date.getPreviousStartDayMonday <= item.date! {
                totalDeletedItems = totalDeletedItems + item.amount
            }
            
            modelContext.delete(item)
            
            item.budget.itemDeletedFor(expense: item, modelContext: modelContext)
        }
        
        totalWeekExpenses = totalWeekExpenses.arithmeticOperation(of: totalDeletedItems, .sub)!
        
        do {
            let fetchDescriptor = FetchDescriptor<Expense>()
            let fetchExpenses = try modelContext.fetch(fetchDescriptor)
            
            if fetchExpenses.isEmpty {
                isExpensesEmpty = true
            }
            
        } catch {
            fatalError("Error deleting expenses")
        }
    }

}
