//
//  StringBacked.swift
//  Canvas
//
//  Created by 刘志达 on 2020/4/1.
//  Copyright © 2020 joylife. All rights reserved.
//

protocol StringRepresentable: CustomStringConvertible {
    init?(_ value: String)
}

struct StringBacked<Value: StringRepresentable>: Codable {
    var value: Value
    
    init(_ value: Value) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
                
        guard let value = Value(string) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: """
                Failed to convert an instance of \(Value.self) from "\(string)"
                """
            )
        }
        
        self.value = value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value.description)
    }
}
