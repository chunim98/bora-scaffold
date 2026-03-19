//
//  Publisher+.swift
//  BoraScaffold
//
//  Created by 신정욱 on 6/2/25.
//

import Foundation
import Combine

extension Publisher {
    
    /// RxSwift `withLatestFrom` 과 같은 동작
    /// - Parameter other: 최신 값을 가져올 퍼블리셔
    /// - Returns: (self 출력, other 최신 출력)을 원하는 형태로 매핑한 퍼블리셔
    func withLatestFrom<Other: Publisher, Result>(
        _ other: Other,
        resultSelector: @escaping (Output, Other.Output) -> Result
    ) -> AnyPublisher<Result, Failure> where Other.Failure == Failure {
        
        // 다른 퍼블리셔의 최신 값을 보관할 subject
        let latest = CurrentValueSubject<Other.Output?, Never>(nil)
        
        // other 의 모든 값을 최신으로 저장
        let latestCancellable = other.sink(
            receiveCompletion: { _ in },
            receiveValue: { latest.send($0) }
        )
        
        // self 가 값을 방출할 때마다 최신 값을 붙여서 내보냄
        return self.compactMap { value -> Result? in
            guard let otherValue = latest.value else { return nil }
            return resultSelector(value, otherValue)
        }
        .handleEvents(receiveCancel: {
            latestCancellable.cancel() // 메모리 누수 방지
        })
        .eraseToAnyPublisher()
    }
    
    /// resultSelector를 사용하지 않는 withLatestFrom
    func withLatestFrom<Other: Publisher>(
        _ other: Other
    ) -> AnyPublisher<Other.Output, Failure> where Other.Failure == Failure {
        
        // 다른 퍼블리셔의 최신 값을 보관할 subject
        let latest = CurrentValueSubject<Other.Output?, Never>(nil)
        
        // other 의 모든 값을 최신으로 저장
        let latestCancellable = other.sink(
            receiveCompletion: { _ in },
            receiveValue: { latest.send($0) }
        )
        
        // self 가 값을 방출할 때마다 최신 값을 붙여서 내보냄
        return self
            .compactMap { _ in latest.value }
            .handleEvents(receiveCancel: {
                latestCancellable.cancel() // 메모리 누수 방지
            })
            .eraseToAnyPublisher()
    }
    
    /// Result 스트림에서 성공(Success) 값만 필터링하여 추출
    func onlyValues<Value, ResultFailure>() -> AnyPublisher<Value, Never>
    where Output == Result<Value, ResultFailure>, Failure == Never {
        return self
            .compactMap { result -> Value? in
                // 패턴 매칭으로 성공 값만 꺼내고, 실패인 경우는 nil을 반환해 스트림에서 무시
                guard case let .success(value) = result else { return nil }
                return value
            }
            .eraseToAnyPublisher()
    }
    
    /// Result 스트림에서 실패(Failure) 에러만 필터링하여 추출
    func onlyErrors<Value, ResultFailure>() -> AnyPublisher<ResultFailure, Never>
    where Output == Result<Value, ResultFailure>, Failure == Never {
        return self
            .compactMap { result -> ResultFailure? in
                // 패턴 매칭으로 에러만 꺼내고, 성공인 경우는 nil을 반환해 스트림에서 무시
                guard case let .failure(error) = result else { return nil }
                return error
            }
            .eraseToAnyPublisher()
    }
}
