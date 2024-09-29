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
        case totalIncomes
        case totalExpenses
    }
    
    var id: UUID
    var title: String
    var note: String
    var date: Date?
    var createdDate: Date
    var updatedDate: Date
    var isTimeEnabled: Bool
    
    @Relationship(deleteRule: .cascade) var expenses = [Expense]()
    @Relationship(deleteRule: .cascade) var incomes = [Income]()
    
    var totalExpenses: Decimal
    var totalIncomes: Decimal
    
    var totalBudget: Decimal {
        totalIncomes - totalExpenses
    }
    
    init(title: String, note: String, date: Date, createdDate: Date, updatedDate: Date, isTimeEnabled: Bool) {
        self.id = UUID()
        self.title = title
        self.note = note
        self.date = date
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.isTimeEnabled = isTimeEnabled
        self.totalIncomes = 0
        self.totalExpenses = 0
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
        totalIncomes = try container.decode(Decimal.self, forKey: .totalIncomes)
        totalExpenses = try container.decode(Decimal.self, forKey: .totalExpenses)
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
        try container.encode(totalIncomes, forKey: .totalIncomes)
        try container.encode(totalExpenses, forKey: .totalExpenses)
    }
}

extension Budget {
    static var previewItem: Budget {
        Budget(title: "Shopping", note: "Monthly shopping", date: Date.distantPast, createdDate: .now, updatedDate: .now, isTimeEnabled: true)
    }
}
