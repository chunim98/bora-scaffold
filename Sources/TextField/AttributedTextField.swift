//
//  AttributedTextField.swift
//  BoraScaffold
//
//  Created by 신정욱 on 4/8/26.
//

import UIKit

class AttributedTextField: UITextField {
    
    // MARK: Properties
    
    /// 기본 플레이스홀더 속성
    var defaultPlaceholderAttributes = [NSAttributedString.Key: Any]() {
        didSet { updateAttributedPlaceholder(with: placeholder) }
    }
    
    /// 일반 플레이스홀더를 설정하면 기본 속성을 적용해 attributedText로 변환
    override var placeholder: String? {
        get { attributedPlaceholder?.string }
        set { updateAttributedPlaceholder(with: newValue) }
    }
    
    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaults()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Defaults
    
    private func setupDefaults() {
        autocapitalizationType = .none  // 자동 대문자 비활성화
        textContentType = .oneTimeCode  // 강력한 비번 생성 방지
    }
    
    // MARK: Private Helpers
    
    /// 문자열에 기본 플레이스홀더 속성을 적용해 attributedText 갱신
    private func updateAttributedPlaceholder(with text: String?) {
        attributedPlaceholder = text.map {
            NSAttributedString(string: $0, attributes: defaultPlaceholderAttributes)
        }
    }
}
