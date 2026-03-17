//
//  PopGestureNavigationController.swift
//  BoraScaffold
//
//  Created by 신정욱 on 3/6/26.
//

import UIKit
import Combine

/// 뷰 컨트롤러별 Pop 제스처 활성화 여부를 제어할 수 있는 네비게이션 컨트롤러
/// - Important: `topViewController`가 ``PopGestureControllable``을 채택한 경우에만 제어가 적용됨
final class PopGestureNavigationController: UINavigationController {
    
    // MARK: Subjects
    
    /// `gestureRecognizerShouldBegin` 호출 이벤트 서브젝트 (출력)
    private let popGestureDetectedSubject = PassthroughSubject<Void, Never>()
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
    }
    
    // MARK: Defaults
    
    private func setupDefaults() {
        if #available(iOS 26.0, *) {
            interactiveContentPopGestureRecognizer?.delegate = self
            interactivePopGestureRecognizer?.isEnabled = false
        } else {
            interactivePopGestureRecognizer?.delegate = self
        }
    }
}

// MARK: Binders & Publishers

extension PopGestureNavigationController {
    /// `gestureRecognizerShouldBegin`가 호출될 때 발생하는 이벤트 퍼블리셔
    /// - 현재 `topViewController`와 `target`이 같은 경우에만 이벤트를 전달함
    /// - Parameter target: 이벤트를 구독할 뷰 컨트롤러
    func popGestureDetectedPublisher(
        from target: UIViewController
    ) -> AnyPublisher<Void, Never> {
        popGestureDetectedSubject
            .filter { [weak self, weak target] in
                self?.topViewController === target
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension PopGestureNavigationController: UIGestureRecognizerDelegate {
    /// 실제로 시작되기 직전에 호출돼서, 시작 여부를 결정
    func gestureRecognizerShouldBegin(
        _ gestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        // 외부로 팝제스처 감지 이벤트 전달
        popGestureDetectedSubject.send(())
        // PopGestureControllable 채택 VC면 해당 설정값으로 시작 여부를 결정
        let vc = topViewController.flatMap { $0 as? PopGestureControllable }
        return vc?.isPopGestureEnabled ?? true
    }
}
