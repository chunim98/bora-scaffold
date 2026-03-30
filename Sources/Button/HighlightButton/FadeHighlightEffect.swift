//
//  FadeHighlightEffect.swift
//  BoraScaffold
//
//  Created by 신정욱 on 3/30/26.
//

import UIKit

/// 터치 시작 시 반투명 효과를 즉시 반영하고, 이후 상태 변화는 애니메이션으로 처리하는 효과
final class FadeHighlightEffect: ButtonHighlightEffect {
    
    // MARK: Properties
    
    /// 터치 시작 직후 하이라이트를 애니메이션 없이 적용할지 여부
    private var shouldImmediately = false
    
    // MARK: Highlight Effect Methods
    
    /// 터치 추적 시작 시 즉시 하이라이트 적용 플래그 설정
    func trackingDidBegin(on button: UIButton) {
        shouldImmediately = true
    }
    
    /// 하이라이트 상태에 따라 alpha를 변경
    /// - 최초 터치 시에는 즉시 반영하고, 그 외에는 애니메이션 적용
    func highlightDidChange(to isHighlighted: Bool, on button: UIButton) {
        let alpha: CGFloat = isHighlighted ? 0.64 : 1.0
        
        if isHighlighted && shouldImmediately {
            button.alpha = alpha
            
        } else {
            UIView.animate(
                withDuration: 0.24,
                delay: 0,
                options: [.beginFromCurrentState, .allowUserInteraction],
                animations: { [weak button] in button?.alpha = alpha }
            )
        }
        
        shouldImmediately = false
    }
    
    func trackingDidEnd(on button: UIButton) {}
    
    func trackingDidCancel(on button: UIButton) {}
}
