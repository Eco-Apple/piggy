//
//  BundleDecodable.swift
//  Piggy
//
//  Created by Jerico Villaraza on 9/5/24.
//

import Foundation

extension Bundle {
    func decode<T: Codable>(_ file: String) -> T? {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            debugPrint("Failed to locate \(file) in bundle.")
            return nil
        }
        guard let data = try? Data(contentsOf: url) else {
            debugPrint("Failed to load \(file) from bundle.")
            return nil
        }
        
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch DecodingError.keyNotFound(let key, let context) {
            debugPrint("Failed to decode \(file) from bundle due to missing key '\(key.stringValue)' - \(context.debugDescription)")
            return nil
        } catch DecodingError.typeMismatch(_, let context) {
            debugPrint("Failed to decode \(file) from bundle due to type mismatch - \(context.debugDescription)")
            return nil
        } catch DecodingError.valueNotFound(let type, let context) {
            debugPrint("Failed to decode \(file) from bundle due to missing \(type) value - \(context.debugDescription)")
            return nil
        } catch DecodingError.dataCorrupted(_) {
            debugPrint("Failed to decode \(file) from bundle because it appears to be invalid JSON.")
            return nil
        } catch {
            debugPrint("Failed to decode \(file) from bundle: \(error.localizedDescription)")
            return nil
        }
    }
}
