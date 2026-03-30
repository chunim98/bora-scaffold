//
//  ButtonHighlightEffect.swift
//  BoraScaffold
//
//  Created by 신정욱 on 3/30/26.
//

import UIKit

/// 버튼의 하이라이트 관련 이벤트를 받아 시각 상태 변화를 적용하는 객체
@MainActor
protocol ButtonHighlightEffect: AnyObject {
    /// 터치 추적이 시작될 때 호출
    /// - 최초 입력에 대한 즉시 반영 판단에 활용
    func trackingDidBegin(on button: UIButton)

    /// 하이라이트 상태가 변경될 때 호출
    /// - 효과 구현체가 강조 UI를 갱신
    func highlightDidChange(to isHighlighted: Bool, on button: UIButton)

    /// 터치 추적이 정상적으로 종료될 때 호출
    /// - 내부 상태 정리가 필요하면 여기서 처리
    func trackingDidEnd(on button: UIButton)

    /// 터치 추적이 취소될 때 호출
    /// - 중간 상태를 정리하거나 복구할 때 사용
    func trackingDidCancel(on button: UIButton)
}
