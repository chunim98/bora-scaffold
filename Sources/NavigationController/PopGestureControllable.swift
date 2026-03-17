//
//  PopGestureControllable.swift
//  BoraScaffold
//
//  Created by 신정욱 on 3/9/26.
//

import UIKit

/// 뷰 컨트롤러별로 Pop 제스처 활성화 여부를 제어하기 위한 프로토콜
/// - Important: 해당 뷰 컨트롤러의 `navigationController`가 ``PopGestureNavigationController``일 때만 적용됨
protocol PopGestureControllable: UIViewController {
    /// Pop 제스처 활성화 여부
    /// - ``PopGestureNavigationController``의 `gestureRecognizerShouldBegin` 반환값으로 사용됨
    var isPopGestureEnabled: Bool { get }
}

extension PopGestureControllable {
    /// 현재 뷰 컨트롤러의 `navigationController`를 ``PopGestureNavigationController``로 캐스팅해 반환
    var popGestureNavigation: PopGestureNavigationController? {
        self.navigationController as? PopGestureNavigationController
    }
}
