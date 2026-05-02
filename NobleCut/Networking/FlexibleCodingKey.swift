//
//  FlexibleCodingKey.swift
//  NobleCut
//
//  Created by Artak Ter-Stepanyan on 02.05.26.
//

import Foundation

struct FlexibleCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    init?(intValue: Int) {
        stringValue = String(intValue)
        self.intValue = intValue
    }
}

extension KeyedDecodingContainer where Key == FlexibleCodingKey {
    func decode<T: Decodable>(_ type: T.Type, forAnyOf keys: [String]) throws -> T {
        for key in keys {
            guard let codingKey = FlexibleCodingKey(stringValue: key) else {
                continue
            }

            if let value = try decodeIfPresent(T.self, forKey: codingKey) {
                return value
            }
        }

        throw DecodingError.keyNotFound(
            FlexibleCodingKey(stringValue: keys.first ?? "") ?? FlexibleCodingKey(stringValue: "unknown")!,
            .init(codingPath: codingPath, debugDescription: "Missing keys: \(keys.joined(separator: ", "))")
        )
    }

    func decodeIfPresent<T: Decodable>(_ type: T.Type, forAnyOf keys: [String]) throws -> T? {
        for key in keys {
            guard let codingKey = FlexibleCodingKey(stringValue: key) else {
                continue
            }

            if let value = try decodeIfPresent(T.self, forKey: codingKey) {
                return value
            }
        }

        return nil
    }
}
