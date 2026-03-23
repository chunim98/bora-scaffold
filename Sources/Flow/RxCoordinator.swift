//
//  RxCoordinator.swift
//  BoraScaffold
//
//  Created by 신정욱 on 3/23/26.
//

import UIKit

import RxSwift

/// 앱의 네비게이션 흐름을 제어하는 기본 단위
class RxCoordinator: NSObject {
    
    // MARK: Properties
    
    /// 하위 흐름을 관리하기 위한 자식 코디네이터 참조 배열
    /// - Note: 자식의 생명주기를 유지하기 위해 강한 참조를 보관해야 함
    var children: [RxCoordinator] = []
    
    /// 화면 전환을 수행할 내비게이션 컨트롤러
    let navigation: UINavigationController
    
    let bag = DisposeBag()
    
    // MARK: Subjects
    
    /// 코디네이터 종료 이벤트 서브젝트 (출력)
    fileprivate let did​FinishSubject = PublishSubject<Void>()
    
    // MARK: Life Cycle
    
    init(navigation: UINavigationController) {
        print("[\(type(of: self))] 시작")
        self.navigation = navigation
    }
    
    deinit { print("[\(type(of: self))] 종료") }
    
    // MARK: Helpers
    
    /// 특정 자식 코디네이터를 해제하여 메모리에서 제거
    func free(child : RxCoordinator?) {
        children.removeAll { $0 === child }
    }
    
    /// 자식 코디네이터를 배열에 추가하여 생명주기 관리 시작
    func store(child: RxCoordinator) {
        children.append(child)
    }
    
    /// 코디네이터 종료 이벤트 외부(부모)에 전달
    func finish() {
        did​FinishSubject.onNext(())
    }
}

// MARK: Reactive Interface

extension Reactive where Base: RxCoordinator {
    /// 코디네이터 종료 이벤트 스트림
    /// - 부모에서 이 이벤트를 구독해서 자식을 정리
    var did​Finish: Observable<Void> { base.did​FinishSubject }
}
