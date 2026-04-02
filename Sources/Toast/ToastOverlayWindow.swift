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
    
    // MARK: Hit Test
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        if hitView === rootViewController?.view { return nil }
        
        return hitView
    }
}
