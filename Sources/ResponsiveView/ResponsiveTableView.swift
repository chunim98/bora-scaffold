//
//  ResponsiveTableView.swift
//  BoraScaffold
//
//  Created by 신정욱 on 12/19/25.
//

import UIKit

/// 버튼 반응 느린 거 속 터져서 만듦
class ResponsiveTableView: UITableView {
    
    // MARK: Life Cycle
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        delaysContentTouches = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Overrides
    
    // 터치된 뷰에 따라 스크롤 우선권 결정
    override func touchesShouldCancel(in view: UIView) -> Bool {
        // UIButton, UITextField는 스크롤 우선
        if view is UIButton || view is UITextField {
            return true
        }
        
        // UITextView는 자체 스크롤 가능하면 터치 유지
        if let textView = view as? UITextView {
            return !textView.isScrollEnabled
        }
        
        // 나머지는 기본 동작
        return super.touchesShouldCancel(in: view)
    }
}
