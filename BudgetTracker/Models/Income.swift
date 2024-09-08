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

    init(title: String, note: String, amount: Decimal, date: Date?, createdDate: Date, updateDate: Date, isTimeEnabled: Bool) {
        self.title = title
        self.note = note
        self.amount = amount
        self.date = date
        self.createdDate = createdDate
        self.updatedDate = updateDate
        self.isTimeEnabled = isTimeEnabled
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.note = try container.decode(String.self, forKey: .note)
        self.amount = try container.decode(Decimal.self, forKey: .amount)
        self.date = try container.decode(Date.self, forKey: .date)
        self.createdDate = try container.decode(Date.self, forKey: .createdDate)
        self.updatedDate = try container.decode(Date.self, forKey: .updatedDate)
        self.isTimeEnabled = try container.decode(Bool.self, forKey: .isTimeEnabled)
    }
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.note, forKey: .note)
        try container.encode(self.amount, forKey: .amount)
        try container.encode(self.date, forKey: .date)
        try container.encode(self.createdDate, forKey: .createdDate)
        try container.encode(self.updatedDate, forKey: .updatedDate)
        try container.encode(self.isTimeEnabled, forKey: .isTimeEnabled)
    }

}

extension Income {
    static var previewItem: Income {
        Income(title: "Shopping", note: "Monthly shopping", amount: 100.0, date: Date.distantPast, createdDate: .now, updateDate: .now, isTimeEnabled: false)
    }
}

