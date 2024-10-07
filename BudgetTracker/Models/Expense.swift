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
    }
    
    private(set) var id: UUID
    private(set) var title: String
    private(set) var note: String
    private(set) var amount: Decimal
    private(set) var date: Date
    private(set) var createdDate: Date
    private(set) var updatedDate: Date
    
    private(set) var isTimeEnabled: Bool
    
    private(set) var budget: Budget?
    
    init(title: String, note: String, amount: Decimal, date: Date, createdDate: Date, updateDate: Date, isTimeEnabled: Bool, budget: Budget) {
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
    }
}

extension Expense {
    static var previewItem: Expense {
        Expense(title: "Shopping", note: "Monthly shopping", amount: 100.0, date: Date.distantPast, createdDate: .today, updateDate: .today, isTimeEnabled: false, budget: .previewItem)
    }
    
    func save(modelContext: ModelContext) {
        guard let budget = self.budget else { fatalError("Missing budget") }
        
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
        
        var expenseFirstDayOfWeek: Date {
            get {
                UserDefaults.standard.object(forKey: "expenseFirstDayOfWeek") as? Date ?? .distantPast
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "expenseFirstDayOfWeek")
            }
        }
        
        totalWeekExpenses = totalWeekExpenses.arithmeticOperation(of: self.amount, .add)!
        modelContext.insert(self)
        budget.addOrSub(amount: self.amount, operation: .sub, expense: self)
        isWeekExpenseEmpty = false
    }
    
    func edit(title: String, note: String, amount: Decimal, date: Date, isTimeEnabled: Bool, budget: Budget){
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
        
        totalWeekExpenses = totalWeekExpenses.arithmeticOperation(of: oldAmount, .sub)!
        totalWeekExpenses = totalWeekExpenses.arithmeticOperation(of: amount, .add)!
        
        self.setBudget(budget, oldAmount: oldAmount)
    }
    
    private func setBudget(_ newBudget: Budget, oldAmount: Decimal) {
        
        guard let budget = self.budget else { fatalError("Missing budget") }
        
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
            
            totalBudget = totalBudget.arithmeticOperation(of: oldAmount, .add)!; #warning ("This will break if user edit budget previous week")
            totalBudget = totalBudget.arithmeticOperation(of: amount, .sub)!; #warning ("This will break if user edit budget previous week")
        } else {
            budget.decreaseTotalExpense(to: oldAmount)
            newBudget.increaseTotalExpense(to: amount)
            
            budget.removeExpense(of: self)
            newBudget.addExpense(of: self)
            
            totalBudget = totalBudget.arithmeticOperation(of: oldAmount, .add)!; #warning ("This will break if user edit budget previous week")
            totalBudget = totalBudget.arithmeticOperation(of: amount, .sub)!; #warning ("This will break if user edit budget previous week")
        }
    }
    
    #if DEBUG
    func setMockDate(at date: Date) {
        self.date = date
    }
    
    func setMockBudget(at budget: Budget) {
        self.budget = budget
    }
    
    func setMockID() {
        self.id = UUID()
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
        
        var totalDeletedItems: Decimal = 0.0
        
        for item in self {
            if Date.getPreviousStartDayMonday <= item.date {
                totalDeletedItems = totalDeletedItems + item.amount
            }
            
            modelContext.delete(item)
            
            item.budget!.itemDeletedFor(expense: item, modelContext: modelContext)
        }
        
        totalWeekExpenses = totalWeekExpenses.arithmeticOperation(of: totalDeletedItems, .sub)!
        
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
