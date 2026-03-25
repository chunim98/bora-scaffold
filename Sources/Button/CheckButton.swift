//
//  CheckButton.swift
//  BoraScaffold
//
//  Created by 신정욱 on 3/25/26.
//

import UIKit

/// 선택 상태 별 스타일을 지정할 수 있는 버튼
/// - Note: 상태는 외부에서 관리해줄 것을 권장
final class CheckButton: UIButton {
    
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
    
    /// 기본 이미지
    var defaultImage: UIImage? {
        didSet { setNeedsUpdateConfiguration() }
    }
    
    /// 선택됨 이미지
    var selectedImage: UIImage? {
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
        // 기본 외형 설정
        var config = UIButton.Configuration.plain()
        config.background.backgroundColor = .clear
        config.contentInsets = .zero
        config.imagePadding = 12
        configuration = config
        
        // 상태 변화에 따라 스타일 덮어쓰기
        configurationUpdateHandler = { [weak self] _ in
            guard let self, var config = configuration else { return }
            
            // 어트리뷰트 타이틀 설정
            applyTitle(title, attrs: defaultTitleAttributes, for: &config)
            
            // 상태에 따라 맞는 이미지 적용
            config.image = isSelected ? selectedImage : defaultImage
            
            // 최종 configuration 반영
            configuration = config
        }
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
