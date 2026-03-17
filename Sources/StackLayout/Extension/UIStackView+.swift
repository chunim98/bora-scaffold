//
//  UIStackView+.swift
//  BoraScaffold
//
//  Created by 신정욱 on 11/14/25.
//

import UIKit

extension UIStackView {
    convenience init(
        _ axis: NSLayoutConstraint.Axis = .horizontal,
        alignment: UIStackView.Alignment = .fill,
        spacing: CGFloat = 0,
        inset: NSDirectionalEdgeInsets? = nil
    ) {
        self.init()
        self.axis = axis
        self.alignment = alignment
        self.spacing = spacing
        
        if let inset {
            self.isLayoutMarginsRelativeArrangement = true
            self.insetsLayoutMarginsFromSafeArea = false // 세이프에어리어 자동 합산 끔
            self.directionalLayoutMargins = inset
        }
    }
    
    var inset: NSDirectionalEdgeInsets {
        get { self.directionalLayoutMargins }
        set {
            self.isLayoutMarginsRelativeArrangement = true
            self.insetsLayoutMarginsFromSafeArea = false // 세이프에어리어 자동 합산 끔
            self.directionalLayoutMargins = newValue
        }
    }
}
