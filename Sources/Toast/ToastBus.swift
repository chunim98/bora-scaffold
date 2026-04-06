//
//  ToastBus.swift
//  BoraScaffold
//
//  Created by 신정욱 on 4/6/26.
//

import Foundation

import RxSwift

@MainActor
final class ToastBus: NSObject {
    
    // MARK: Singleton
    
    static let shared = ToastBus()
    private override init() { super.init() }
    
    // MARK: Properties
    
    /// 토스트 노출 서브젝트
    fileprivate let presentSubject = PublishSubject<String>()
}

// MARK: Reactive Interface

@MainActor
extension Reactive where Base: ToastBus {
    /// 토스트 메시지 노출
    func present(message: String) { base.presentSubject.onNext(message) }
    
    /// 토스트 메시지 노출 스트림
    /// - 메시지 문자열과 함께 전달
    var presentTrigger: Observable<String> { base.presentSubject }
}
