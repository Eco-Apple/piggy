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
    
    var id: UUID
    var title: String
    var note: String
    var amount: Decimal
    var date: Date?
    var createdDate: Date
    var updatedDate: Date
    var isTimeEnabled: Bool
    
    var budget: Budget?

    init(title: String, note: String, amount: Decimal, date: Date?, createdDate: Date, updatedDate: Date, isTimeEnabled: Bool, budget: Budget?) {
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
}
