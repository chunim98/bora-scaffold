//
//  ScaleHilightButton.swift
//  BoraScaffold
//
//  Created by 신정욱 on 3/10/26.
//

import UIKit
import Combine

/// 하이라이트 상태 변화에 따라 scale + alpha 애니메이션을 적용하는 버튼
class ScaleHilightButton: UIButton {
    
    // MARK: Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Bindings
    
    private func setupBindings() {
        // 주어진 하이라이트 상태로 UI 갱신
        publisher(for: \.isHighlighted)
            .removeDuplicates()
            .sink { [weak self] in self?.updateUI(isHighlighted: $0) }
            .store(in: &cancellables)
    }
}

// MARK: Binders & Publishers

extension ScaleHilightButton {
    /// 주어진 하이라이트 상태로 UI 갱신
    private func updateUI(isHighlighted: Bool) {
        /// 스케일
        let scale = isHighlighted
        ? CGAffineTransform(scaleX: 0.96, y: 0.96)
        : .identity
        /// 불투명도
        let alpha: CGFloat = isHighlighted ? 0.8 : 1.0
        
        UIView.animate(
            withDuration: 0.08,
            delay: 0,
            options: [
                .beginFromCurrentState,
                .allowUserInteraction
            ],
            animations: { [weak self] in
                self?.transform = scale
                self?.alpha = alpha
            }
        )
    }
}
