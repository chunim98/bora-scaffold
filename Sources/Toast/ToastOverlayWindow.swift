//
//  ToastOverlayWindow.swift
//  BoraScaffold
//
//  Created by 신정욱 on 4/2/26.
//

import UIKit

final class ToastOverlayWindow: UIWindow {
    
    // MARK: Properties
    
    override var canBecomeKey: Bool { false }
    
    // MARK: Life Cycle
    
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        setupDefaults()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Defaults
    
    private func setupDefaults() {
        rootViewController = ToastHostVC()
        windowLevel = .normal + 1
        backgroundColor = .clear
        isOpaque = false
        isHidden = false
    }
    
    // MARK: Hit Test
    
    /// 평소에는 아래에 깔린 윈도우로 터치 이벤트 전파, 토스트 영역 터치만 이벤트를 삼킴
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        if hitView === rootViewController?.view { return nil }
        
        return hitView
    }
}
