//
//  AttributedButton.swift
//  BoraScaffold
//
//  Created by 신정욱 on 3/30/26.
//

import UIKit

class AttributedButton: HighlightButton {
    
    // MARK: Properties
    
    /// 기본 타이틀 속성
    var defaultTitleAttributes: AttributeContainer? {
        didSet { setNeedsUpdateConfiguration() }
    }
    
    /// 일반 텍스트를 설정하면 기본 속성을 적용해 attributedTitle로 변환
    var title: String? {
        didSet { setNeedsUpdateConfiguration() }
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
        if configuration == nil { configuration = .plain() }
    }
    
    // MARK: Overrides
    
    override func updateConfiguration() {
        super.updateConfiguration()
        guard var configuration, let title else { return }
        
        configuration.attributedTitle = AttributedString(
            title,
            attributes: defaultTitleAttributes ?? .init()
        )
        
        self.configuration = configuration
    }
}
