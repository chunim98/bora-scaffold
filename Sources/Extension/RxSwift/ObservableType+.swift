//
//  ObservableType+.swift
//  BoraScaffold
//
//  Created by 신정욱 on 3/19/26.
//

import RxSwift

extension ObservableType {
    /// Result 스트림에서 성공 값만 추출
    func onlyValues<Value, Failure>() -> Observable<Value>
    where Element == Result<Value, Failure> {
        compactMap { result -> Value? in
            guard case let .success(value) = result else { return nil }
            return value
        }
    }
    
    /// Result 스트림에서 실패 값만 추출
    func onlyErrors<Value, Failure>() -> Observable<Failure>
    where Element == Result<Value, Failure> {
        compactMap { result -> Failure? in
            guard case let .failure(error) = result else { return nil }
            return error
        }
    }
}
