//
//  AlertButton.swift
//  BoraScaffold
//
//  Created by 신정욱 on 11/18/25.
//

import UIKit

import SnapKit

final class AlertButton: UIButton {
    
    // MARK: Properties
    
    /// 기본 타이틀 속성
    /// - Note: `foregroundColor`, `underlineColor` 속성은 스타일 정책에 의해 무시됨
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
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Defaults
    
    private func setupDefaults() {
        // 기본 외형 설정
        var config = UIButton.Configuration.plain()
        config.background.cornerRadius = 0
        config.cornerStyle = .fixed
        configuration = config
        
        // 상태 변화에 따라 스타일 덮어쓰기
        configurationUpdateHandler = { [weak self] _ in
            guard let self, var config = configuration else { return }
            
            // 어트리뷰트 타이틀 설정
            applyTitle(title, attrs: defaultTitleAttributes, for: &config)
            
            // 하이라이트 상태에 따라 배경색을 동적으로 변경
            config.background.backgroundColor = isHighlighted ? .secondarySystemBackground : .systemBackground
            
            // 최종 configuration 반영
            self.configuration = config
        }
    }
    
    // MARK: Layout
    
    private func setupLayout() {
        self.snp.makeConstraints { $0.height.equalTo(54) }
    }
    
    // MARK: Private Helper
    
    /// 어트리뷰트 타이틀을 Configuration에 매핑
    private func applyTitle(
        _ title: String?,
        attrs: AttributeContainer?,
        for config: inout UIButton.Configuration
    ) {
        config.attributedTitle = title.map {
            let attributes = defaultTitleAttributes ?? .init()
            return AttributedString($0, attributes: attributes)
        }
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    var attrs = TextAttributes()
    attrs.font = .systemFont(ofSize: 18, weight: .semibold)
    attrs.foregroundColor = .label
    attrs.lineHeight = .percent(120)
    let button = AlertButton()
    button.defaultTitleAttributes = attrs.toContainer()
    button.title = "확인"
    return button
}
