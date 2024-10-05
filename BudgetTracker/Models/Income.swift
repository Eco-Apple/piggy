//
//  Budget.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 9/7/24.
//

import Foundation
import SwiftData

@Model
class Income: Codable {
    
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

    init(title: String, note: String, amount: Decimal, date: Date?, createdDate: Date, updatedDate: Date, isTimeEnabled: Bool, budget: Budget) {
        self.id = UUID()
        self.title = title
        self.note = note
        self.amount = amount
        self.date = date
        self.createdDate = createdDate
        self.updatedDate = updatedDate
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

extension Income {
    static var previewItem: Income {
        Income(title: "Shopping", note: "Monthly shopping", amount: 100.0, date: Date.distantPast, createdDate: .now, updatedDate: .now, isTimeEnabled: false, budget: .previewItem)
    }
    
    func save(modelContext: ModelContext) {
        var totalWeekIncomes: String {
            get {
                UserDefaults.standard.string(forKey: "totalWeekIncomes") ?? "0.0"
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "totalWeekIncomes")
            }
        }
        
        var isIncomesEmpty: Bool {
            get {
                UserDefaults.standard.bool(forKey: "isIncomesEmpty")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "isIncomesEmpty")
            }
        }
        
        totalWeekIncomes = totalWeekIncomes.arithmeticOperation(of: self.amount, .add)!
        modelContext.insert(self)
        self.budget.addOrSub(amount: self.amount, operation: .add, income: self)
        isIncomesEmpty = false
    }
    
    func edit(title: String, note: String, amount: Decimal, date: Date, isTimeEnabled: Bool, budget: Budget){
        let oldAmount = self.amount
        
        self.title = title
        self.note = note
        self.amount = amount
        self.date = date
        self.isTimeEnabled = isTimeEnabled
        self.updatedDate = .now
        
        var totalWeekIncomes: String {
            get {
                UserDefaults.standard.string(forKey: "totalWeekIncomes") ?? "0.0"
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "totalWeekIncomes")
            }
        }
        
        totalWeekIncomes = totalWeekIncomes.arithmeticOperation(of: oldAmount, .sub)!
        totalWeekIncomes = totalWeekIncomes.arithmeticOperation(of: amount, .add)!
        
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
            budget.decreaseTotalIncome(to: oldAmount)
            budget.increaseTotalIncome(to: amount)
            
            totalWeekBudgets = totalWeekBudgets.arithmeticOperation(of: oldAmount, .sub)!; #warning ("This will break if user edit budget previous week")
            totalWeekBudgets = totalWeekBudgets.arithmeticOperation(of: amount, .add)!; #warning ("This will break if user edit budget previous week")
        } else {
            budget.decreaseTotalIncome(to: oldAmount)
            newBudget.increaseTotalIncome(to: amount)
            
            budget.removeIncome(of: self)
            newBudget.addIncome(of: self)
            
            totalWeekBudgets = totalWeekBudgets.arithmeticOperation(of: oldAmount, .sub)!; #warning ("This will break if user edit budget previous week")
            totalWeekBudgets = totalWeekBudgets.arithmeticOperation(of: amount, .add)!; #warning ("This will break if user edit budget previous week")
        }
    }

}

extension [Income] {

    func delete(modelContext: ModelContext) {
        var totalWeekIncomes: String {
            get {
                UserDefaults.standard.string(forKey: "totalWeekIncomes") ?? "0.0"
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "totalWeekIncomes")
            }
        }
        
        
        var isIncomesEmpty: Bool {
            get {
                UserDefaults.standard.bool(forKey: "isIncomesEmpty")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "isIncomesEmpty")
            }
        }
        
        let today = Date.now
        let calendar = Calendar.current

        let weekday = calendar.component(.weekday, from: today)
        

        let daysToMonday = (weekday == 1 ? -6 : 2 - weekday)
        
        guard let monday = calendar.date(byAdding: .day, value: daysToMonday, to: today)?.localStartOfDate else { return }
        
        var totalDeletedItems: Decimal = 0.0
        
        for item in self {
            if monday <= item.date! {
                totalDeletedItems = totalDeletedItems + item.amount
            }
            
            modelContext.delete(item)
            item.budget.itemDeletedFor(income: item, modelContext: modelContext)
        }
        
        totalWeekIncomes = totalWeekIncomes.arithmeticOperation(of: totalDeletedItems, .sub)!
        
        do {
            let fetchDescriptor = FetchDescriptor<Income>()
            let fetchIncomes = try modelContext.fetch(fetchDescriptor)
            
            if fetchIncomes.isEmpty {
                isIncomesEmpty = true
            }
            
        } catch {
            fatalError("Error deleting incomes")
        }
    }
}
