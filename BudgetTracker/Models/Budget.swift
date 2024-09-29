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
        case title
        case note
        case amount
        case date
        case createdDate
        case updatedDate
        case isTimeEnabled
    }
    
    var title: String
    var note: String
    var amount: Decimal
    var date: Date?
    var createdDate: Date
    var updatedDate: Date
    var isTimeEnabled: Bool
    
    @Relationship(deleteRule: .cascade) var expenses = [Expense]()
    
    init(title: String, note: String, amount: Decimal, date: Date, createdDate: Date, updatedDate: Date, isTimeEnabled: Bool) {
        self.title = title
        self.note = note
        self.amount = amount
        self.date = date
        self.createdDate = createdDate
        self.updatedDate = updatedDate
        self.isTimeEnabled = isTimeEnabled
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        note = try container.decode(String.self, forKey: .note)
        amount = try container.decode(Decimal.self, forKey: .amount)
        date = try container.decode(Date.self, forKey: .date)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        updatedDate = try container.decode(Date.self, forKey: .updatedDate)
        isTimeEnabled = try container.decode(Bool.self, forKey: .isTimeEnabled)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(note, forKey: .note)
        try container.encode(amount, forKey: .amount)
        try container.encode(date, forKey: .date)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(updatedDate, forKey: .updatedDate)
        try container.encode(isTimeEnabled, forKey: .isTimeEnabled)
    }
}

extension Budget {
    static var previewItem: Budget {
        Budget(title: "Shopping", note: "Monthly shopping", amount: 100.0, date: Date.distantPast, createdDate: .now, updatedDate: .now, isTimeEnabled: true)
    }
}
