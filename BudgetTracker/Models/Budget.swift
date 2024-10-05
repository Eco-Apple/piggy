//
//  Budget.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 9/21/24.
//

import Foundation
import SwiftData

@Model
class Budget: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case note
        case date
        case createdDate
        case updatedDate
        case isTimeEnabled
        case totalIncome
        case totalExpense
    }
    
    private(set) var id: UUID
    private(set) var title: String
    private(set) var note: String
    private(set) var date: Date?
    private(set) var createdDate: Date
    private(set) var updatedDate: Date
    private(set) var isTimeEnabled: Bool
    
    @Relationship(deleteRule: .cascade) private(set) var expenses = [Expense]()
    @Relationship(deleteRule: .cascade) private(set) var incomes = [Income]()
    
    private(set) var totalExpense: Decimal
    private(set) var totalIncome: Decimal
    
    var totalBudget: Decimal {
        get {
            totalIncome - totalExpense
        }
    }
    
    var isFresh: Bool {
        get {
            totalIncome == 0 && totalExpense == 0
        }
    }
    
    init(title: String, note: String, date: Date, createdDate: Date, updatedDate: Date, isTimeEnabled: Bool) {
        self.id = UUID()
        self.title = title
        self.note = note
        self.date = date
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.isTimeEnabled = isTimeEnabled
        self.totalIncome = 0
        self.totalExpense = 0
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        note = try container.decode(String.self, forKey: .note)
        date = try container.decode(Date.self, forKey: .date)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        updatedDate = try container.decode(Date.self, forKey: .updatedDate)
        isTimeEnabled = try container.decode(Bool.self, forKey: .isTimeEnabled)
        totalIncome = try container.decode(Decimal.self, forKey: .totalIncome)
        totalExpense = try container.decode(Decimal.self, forKey: .totalExpense)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(note, forKey: .note)
        try container.encode(date, forKey: .date)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(updatedDate, forKey: .updatedDate)
        try container.encode(isTimeEnabled, forKey: .isTimeEnabled)
        try container.encode(totalIncome, forKey: .totalIncome)
        try container.encode(totalExpense, forKey: .totalExpense)
    }
}

extension Budget {
    
    enum ArithmeticOperation {
        case add, sub
    }
    
    static var previewItem: Budget {
        Budget(title: "Shopping", note: "Monthly shopping", date: Date.distantPast, createdDate: .now, updatedDate: .now, isTimeEnabled: true)
    }
    
    func save(incomes: [Income], expenses: [Expense], modelContext: ModelContext) {
        var totalWeekBudgets: String {
            get {
                UserDefaults.standard.string(forKey: "totalWeekBudgets") ?? "0.0"
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "totalWeekBudgets")
            }
        }
        
        var isBudgetsEmpty: Bool {
            get {
                UserDefaults.standard.bool(forKey: "isBudgetsEmpty")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "isBudgetsEmpty")
            }
        }
        
        
        var totalIncome: Decimal = 0.0
        var totalExpense: Decimal = 0.0
        
        for income in incomes {
            income.save(modelContext: modelContext)
            totalIncome = totalIncome + income.amount
        }
        
        for expense in expenses {
            expense.save(modelContext: modelContext)
            totalExpense = totalExpense + expense.amount
        }
            
        totalWeekBudgets = totalWeekBudgets.arithmeticOperation(of: totalIncome - totalExpense, .add)!
        
        modelContext.insert(self)
        isBudgetsEmpty = false
    }
    
    func edit(title: String, note: String, date: Date, isTimeEnabled: Bool) {
        self.title = title
        self.note = note
        self.date = date
        self.isTimeEnabled = isTimeEnabled
        self.updatedDate = .now

    }
    
    func addOrSub(amount: Decimal, operation: ArithmeticOperation, expense: Expense? = nil, income: Income? = nil) {
        var totalWeekBudgets: String {
            get {
                UserDefaults.standard.string(forKey: "totalWeekBudgets") ?? "0.0"
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "totalWeekBudgets")
            }
        }
        
        var isBudgetsEmpty: Bool {
            get {
                UserDefaults.standard.bool(forKey: "isBudgetsEmpty")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "isBudgetsEmpty")
            }
        }
        
        switch operation {
            case .add:
                totalWeekBudgets = totalWeekBudgets.arithmeticOperation(of: amount, .add)!
            case .sub:
                totalWeekBudgets = totalWeekBudgets.arithmeticOperation(of: amount, .sub)!
                break
        }
        
        
        if let expense = expense {
            self.totalExpense += amount
            self.expenses.append(expense)
        }
        
        if let income = income {
            self.totalIncome += amount
            self.incomes.append(income)
        }
        
        isBudgetsEmpty = false
    }
    
    func itemDeletedFor(expense: Expense? = nil, income: Income? = nil, modelContext: ModelContext) {
        var totalWeekBudgets: String {
            get {
                UserDefaults.standard.string(forKey: "totalWeekBudgets") ?? "0.0"
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "totalWeekBudgets")
            }
        }
        
        
        if let expense = expense {
            expense.budget.totalExpense -= expense.amount
            totalWeekBudgets = totalWeekBudgets.arithmeticOperation(of: expense.amount, .add)!
        }
        
        if let income = income {
            income.budget.totalIncome -= income.amount
            totalWeekBudgets = totalWeekBudgets.arithmeticOperation(of: income.amount, .sub)!
        }
        
    }
    
    func increaseTotalIncome(to amount: Decimal) {
        totalIncome += amount
    }
    
    func decreaseTotalIncome(to amount: Decimal) {
        totalIncome -= amount
    }
    
    func removeIncome(of income: Income){
        incomes.removeAll { val in
            val == income
        }
    }
    
    func addIncome(of income: Income){
        incomes.append(income)
    }
    
    
    func increaseTotalExpense(to amount: Decimal) {
        totalExpense += amount
    }
    
    func decreaseTotalExpense(to amount: Decimal) {
        totalExpense -= amount
    }
    
    func removeExpense(of expense: Expense){
        expenses.removeAll { val in
            val == expense
        }
    }
    
    func addExpense(of expense: Expense){
        expenses.append(expense)
    }


}

extension [Budget] {
    func delete(modelContext: ModelContext){
        
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
        
        var totalWeekBudgets: String {
            get {
                UserDefaults.standard.string(forKey: "totalWeekBudgets") ?? "0.0"
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "totalWeekBudgets")
            }
        }
        
        var isBudgetsEmpty: Bool {
            get {
                UserDefaults.standard.bool(forKey: "isBudgetsEmpty")
            }
            set {
                UserDefaults.standard.set(newValue, forKey: "isBudgetsEmpty")
            }
        }
        
        
        var totalDeletedIncomes: Decimal = 0.0
        var totalDeletedExpenses: Decimal = 0.0
        
        for budget in self {
            
            for income in budget.incomes {
                if Date.getPreviousStartDayMonday <= income.date! {
                    totalDeletedIncomes += income.amount
                }
            }
            
            for expense in budget.expenses {
                if Date.getPreviousStartDayMonday <= expense.date! {
                    totalDeletedExpenses += expense.amount
                }
            }
            
            modelContext.delete(budget)
        }
        
        totalWeekIncomes = totalWeekIncomes.arithmeticOperation(of: totalDeletedIncomes, .sub)!
        totalWeekExpenses = totalWeekExpenses.arithmeticOperation(of: totalDeletedExpenses, .sub)!
        totalWeekBudgets = totalWeekBudgets.arithmeticOperation(of: totalDeletedIncomes - totalDeletedExpenses, .sub)!
        
        do {
            let fetchBudgetDescriptor = FetchDescriptor<Budget>()
            let fetchBudget = try modelContext.fetch(fetchBudgetDescriptor)
            
            if fetchBudget.isEmpty {
                isBudgetsEmpty = true
            }
            
            
            let fetchIncomeDescriptor = FetchDescriptor<Income>()
            let fetchIncomes = try modelContext.fetch(fetchIncomeDescriptor)
            
            if fetchIncomes.isEmpty {
                isIncomesEmpty = true
            }
            
            let fetchExpenseDescriptor = FetchDescriptor<Expense>()
            let fetchExpenses = try modelContext.fetch(fetchExpenseDescriptor)
            
            if fetchExpenses.isEmpty {
                isExpensesEmpty = true
            }
            
        } catch {
            fatalError("Error deleting budget.")
        }
        
    }
}
