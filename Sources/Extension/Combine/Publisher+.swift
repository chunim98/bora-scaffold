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
    
    /// RxSwift의 `flatMapFirst`처럼 동작하는 오퍼레이터,
    /// inner publisher가 실행 중이면 이후 upstream 값은 무시함
    func flatMapFirst<Inner: Publisher>(
        _ transform: @escaping (Output) -> Inner
    ) -> AnyPublisher<Inner.Output, Failure>
    where Inner.Failure == Failure {
        /// 실행 상태를 보호하는 락
        let lock = NSLock()
        /// 현재 inner publisher 실행 여부
        var isRunning = false
        
        return self
            .filter { _ in
                lock.lock()
                defer { lock.unlock() }
                
                // 현재 실행 중이 아닐 때만 다음 값을 통과
                guard !isRunning else { return false }
                isRunning = true
                return true
            }
            .flatMap { value in
                // 통과된 값으로 inner publisher를 생성
                transform(value)
                    .handleEvents(
                        receiveCompletion: { _ in
                            lock.lock()
                            defer { lock.unlock() }
                            
                            // inner가 완료되면 실행 상태를 해제
                            isRunning = false
                        },
                        receiveCancel: {
                            lock.lock()
                            defer { lock.unlock() }
                            
                            // inner가 취소되면 실행 상태를 해제
                            isRunning = false
                        }
                    )
            }
            .eraseToAnyPublisher()
    }
}
