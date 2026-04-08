//
//  InsetAttributedTextField.swift
//  BoraScaffold
//
//  Created by 신정욱 on 4/8/26.
//

import UIKit

class InsetAttributedTextField: AttributedTextField {
    
    // MARK: Properties
    
    /// 텍스트 필드 바깥 여백
    var inset: UIEdgeInsets = .zero {
        didSet { setNeedsLayout() }
    }
    
    /// leftView와 텍스트 사이 간격
    var leftViewPadding: CGFloat = .zero {
        didSet { setNeedsLayout() }
    }
    
    /// rightView와 텍스트 사이 간격
    var rightViewPadding: CGFloat = .zero {
        didSet { setNeedsLayout() }
    }
    
    // MARK: Overrides
    
    /// 일반 상태에서 표시할 텍스트 영역을 계산
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        contentRect(forBounds: bounds, isEditing: false)
    }
    
    /// 편집 중에 표시할 텍스트 영역을 계산
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        contentRect(forBounds: bounds, isEditing: true)
    }
    
    /// 플레이스홀더가 표시될 영역을 계산
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        contentRect(forBounds: bounds, isEditing: isEditing)
    }
    
    /// leftView를 왼쪽 inset 기준에 맞춰 배치
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var leftViewRect = super.leftViewRect(forBounds: bounds)
        leftViewRect.origin.x = inset.left
        return leftViewRect
    }
    
    /// rightView를 오른쪽 inset 안쪽에 맞춰 배치
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rightViewRect = super.rightViewRect(forBounds: bounds)
        rightViewRect.origin.x = bounds.width - inset.right - rightViewRect.width
        return rightViewRect
    }
    
    // MARK: Private Helpers
    
    /// 기본 inset에 accessory 영역까지 더한 최종 텍스트 영역을 계산
    private func contentRect(forBounds bounds: CGRect, isEditing: Bool) -> CGRect {
        var inset = inset
        inset.left += leftAccessoryInset(forBounds: bounds, isEditing: isEditing)
        inset.right += rightAccessoryInset(forBounds: bounds, isEditing: isEditing)
        return bounds.inset(by: inset)
    }
    
    /// 현재 상태에서 leftView가 차지하는 너비와 padding을 반환
    private func leftAccessoryInset(forBounds bounds: CGRect, isEditing: Bool) -> CGFloat {
        shouldShowView(leftView, mode: leftViewMode, whileEditing: isEditing)
        ? leftViewRect(forBounds: bounds).width + leftViewPadding
        : .zero
    }
    
    /// 현재 상태에서 rightView가 차지하는 너비와 padding을 반환
    private func rightAccessoryInset(forBounds bounds: CGRect, isEditing: Bool) -> CGFloat {
        shouldShowView(rightView, mode: rightViewMode, whileEditing: isEditing)
        ? rightViewRect(forBounds: bounds).width + rightViewPadding
        : .zero
    }
    
    /// ViewMode와 편집 상태를 기준으로 accessory 노출 여부를 판단
    private func shouldShowView(
        _ view: UIView?,
        mode: ViewMode,
        whileEditing isEditing: Bool
    ) -> Bool {
        guard view != nil else { return false }
        
        return switch mode {
        case .never:            false
        case .whileEditing:     isEditing
        case .unlessEditing:    !isEditing
        case .always:           true
        @unknown default:       false
        }
    }
}
