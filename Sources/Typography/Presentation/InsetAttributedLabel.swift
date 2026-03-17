//
//  InsetAttributedLabel.swift
//  BoraScaffold
//
//  Created by 신정욱 on 3/16/26.
//

import UIKit

final class InsetAttributedLabel: AttributedLabel {
    
    // MARK: Properties
    
    private var inset: UIEdgeInsets
    
    // MARK: Life Cycle
    
    init(inset: UIEdgeInsets = .zero) {
        self.inset = inset
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Overrides
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: inset))
    }
    
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += inset.top + inset.bottom
        contentSize.width += inset.left + inset.right
        return contentSize
    }
}
