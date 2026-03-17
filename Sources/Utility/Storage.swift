//
//  Storage.swift
//  BoraScaffold
//
//  Created by 신정욱 on 12/11/25.
//

import Foundation

@propertyWrapper
struct Storage<T: Codable> {
    private let key: String
    private let defaultValue: T?
    
    var wrappedValue: T? {
        get {
            // UserDefaults에서 Data 타입으로 꺼냄
            // Data를 다시 T 타입으로 디코딩 (JSON -> 객체)
            guard let data = UserDefaults.standard.data(forKey: key),
                  let value = try? JSONDecoder().decode(T.self, from: data)
            else { return defaultValue }
            return value
        }
        set {
            if let newValue {
                // 값을 Data로 인코딩 (객체 -> JSON Data)
                if let data = try? JSONEncoder().encode(newValue) {
                    UserDefaults.standard.set(data, forKey: key)
                }
            } else {
                // nil이면 삭제
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
    
    init(
        _ key: String,
        _ defaultValue: T?
    ) {
        self.key = key
        self.defaultValue = defaultValue
    }
}
