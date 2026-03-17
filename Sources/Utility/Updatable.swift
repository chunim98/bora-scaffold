//
//  Updatable.swift
//  BoraScaffold
//
//  Created by 신정욱 on 3/16/26.
//

protocol Updatable {}

extension Updatable {
    /// 주어진 키패스가 가리키는 프로퍼티 값을 갱신한 새로운 인스턴스를 반환
    /// - Note: 원본 인스턴스는 변경되지 않고, 복사본에만 적용됨
    /// - Important: 값 타입을 대상으로 설계됨
    func updated<T>(
        _ path: WritableKeyPath<Self, T>,
        _ newValue: T
    ) -> Self {
        var copy = self
        copy[keyPath: path] = newValue
        return copy
    }
}
