//
//  FadeHighlightButton.swift
//  BoraScaffold
//
//  Created by 신정욱 on 3/17/26.
//

import UIKit

/// 터치 시작 시 페이드 하이라이트를 즉시 반영하고,
/// 이후 상태 변화는 애니메이션으로 처리하는 버튼
class FadeHighlightButton: UIButton {
    
    // MARK: Properties
    
    /// 터치 시작 직후 하이라이트를 애니메이션 없이 적용할지 여부
    private var shouldImmediately = false
    
    // MARK: Overrides
    
    /// 하이라이트 상태가 바뀔 때마다 UI를 갱신
    /// 최초 터치 시에는 즉시 반영하고, 그 외에는 애니메이션 적용
    override var isHighlighted: Bool {
        didSet {
            let shouldAnimate = !(isHighlighted && shouldImmediately)
            updateUI(with: isHighlighted, animated: shouldAnimate)
            shouldImmediately = false
        }
    }
    
    /// 터치 추적 시작 시 즉시 하이라이트 적용 플래그 설정
    override func beginTracking(
        _ touch: UITouch,
        with event: UIEvent?
    ) -> Bool {
        shouldImmediately = true
        return super.beginTracking(touch, with: event)
    }
}

// MARK: Helpers

extension FadeHighlightButton {
    /// 하이라이트 상태에 따라 alpha를 변경
    /// animated가 false면 즉시, true면 애니메이션으로 반영
    private func updateUI(with isHighlighted: Bool, animated: Bool) {
        let alpha: CGFloat = isHighlighted ? 0.64 : 1.0
        guard animated else { self.alpha = alpha; return }
        
        UIView.animate(
            withDuration: 0.24,
            delay: 0,
            options: [.beginFromCurrentState, .allowUserInteraction],
            animations: { [weak self] in self?.alpha = alpha }
        )
    }
}
