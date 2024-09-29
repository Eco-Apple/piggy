//
//  Extensions.swift
//  BudgetTracker
//
//  Created by Jerico Villaraza on 8/10/24.
//

import SwiftUI
import SwiftData

//extension Array where Element: Expense {}

extension Array {
    func getPluralSuffix(singular: String, plural: String) -> String {
        self.count > 1 ? plural : singular
    }
}

extension Collection {
    var isNotEmpty: Bool {
        !self.isEmpty
    }
}

extension Decimal {
    var toStringWithCommaSeparator: String? {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = ""
        
        let result = formatter.string(from: self as NSNumber)

        return result?.toDecimalWithCommaSeparator
    }
}


extension String {
    var toDecimalWithCommaSeparator: String? {
        let components = self.split(separator: ".")
        let integerPart: Substring? = components.first
        let decimalPart: Substring? = components.count > 1 ? components[1] : nil
        let hasDecimal = self.contains(".")
        var result : String? = nil
        
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        formatter.currencySymbol = ""
        
        
        if let integer = integerPart {
            let val = String(integer).replacingOccurrences(of: ",", with: "")
            
            if let formatted = formatter.string(from: Int(val)! as NSNumber) {
                result = formatted
            }
        }
        
        if hasDecimal {
            if integerPart == nil {
                result = "0"
            }
            result = result! + "."
        }
        
        if let decimal = decimalPart {
            let val = String(decimal).prefix(2)
            
            result = result! + val
        }
        
        return result
    }
}


extension String {
    
    enum ArithmeticOperation {
        case add, sub
    }
    
    func arithmeticOperation(of decimal: Decimal, _ operation: ArithmeticOperation ) -> String? {
        
        guard let selfDecimal = Decimal(string: self) else { return nil}
        
        switch operation {
        case .add:
            return "\(selfDecimal + decimal)"
        case .sub:
            return "\(selfDecimal - decimal)"
        }
        
    }
    
}

extension Date {
    
    static var getPreviousStartDayMonday: Date {
        let today = Date.now
        let calendar = Calendar.current

        let weekday = calendar.component(.weekday, from: today)
        

        let daysToMonday = (weekday == 1 ? -6 : 2 - weekday)
        
        let monday = calendar.date(byAdding: .day, value: daysToMonday, to: today)!.localStartOfDate
        
        return monday
    }
    
    var localStartOfDate: Date {
        let startOfDate = Calendar.current.startOfDay(for: self)
        let timezoneOffset = TimeZone.current.secondsFromGMT(for: startOfDate)
        
        let result = startOfDate.addingTimeInterval(TimeInterval(timezoneOffset))
        
        return result
    }

    func format(_ dateStyle: DateStyle, descriptive: Bool = false) -> String {
        let formatter = DateFormatter()
        
        let calendar = Calendar.current
        
        if descriptive {
            if calendar.startOfDay(for: self) == calendar.startOfDay(for: Date.now) {
                return "Today"
            }
            
            if calendar.startOfDay(for: self) == calendar.startOfDay(for: Calendar.current.date(byAdding: .day, value: -1, to: Date.now)!) {
                return "Yesterday"
            }
        }
        
        switch dateStyle {
        case .dateAndTime:
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: self)
        case .dateOnly:
            formatter.dateStyle = .medium
            return formatter.string(from: self)
        case .timeOnly:
            formatter.timeStyle = .short
            return formatter.string(from: self)
        }
    }
    
}
extension Budget {

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
            income.save(selectedBudget: self, modelContext: modelContext)
            totalIncome = totalIncome + income.amount
        }
        
        for expense in expenses {
            expense.save(selectedBudget: self, modelContext: modelContext)
            totalExpense = totalExpense + expense.amount
        }
            
        totalWeekBudgets = totalWeekBudgets.arithmeticOperation(of: totalIncome - totalExpense, .add)!
        
        modelContext.insert(self)
        isBudgetsEmpty = false        
    }
}

extension Expense {
    func save(selectedBudget: Budget, modelContext: ModelContext) {
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
        
        selectedBudget.totalExpenses += self.amount
        selectedBudget.expenses.append(self)
        
        modelContext.insert(self)
        isExpensesEmpty = false
    }
}

extension Income {
    func save(selectedBudget: Budget, modelContext: ModelContext) {
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
        
        selectedBudget.totalIncomes += self.amount
        selectedBudget.incomes.append(self)
        
        modelContext.insert(self)
        isIncomesEmpty = false
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
            item.budget!.totalExpenses -= item.amount
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
            item.budget!.totalIncomes -= item.amount
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
