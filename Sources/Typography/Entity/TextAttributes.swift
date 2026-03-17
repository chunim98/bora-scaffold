//
//  TextAttributes.swift
//  BoraScaffold
//
//  Created by 신정욱 on 3/15/26.
//

import UIKit

/// AttributedString을 구성하는 텍스트 속성 정의
struct TextAttributes: Hashable {
    
    // MARK: Metric
    
    /// 픽셀(px) 또는 퍼센트(%) 단위로 값을 표현하는 타입
    enum Metric: Hashable {
        /// 주어진 값을 '절대값(px)'으로 사용.
        case pixel(CGFloat)
        /// 폰트 크기에 대한 '비율(%)'로 적용.
        case percent(CGFloat)
    }
    
    // MARK: Properties
    
    var font: UIFont = .preferredFont(forTextStyle: .body)
    var foregroundColor: UIColor?
    var alignment: NSTextAlignment? = .natural
    var lineHeight: Metric?
    var letterSpacing: Metric?
    var paragraphSpacing: CGFloat?
    var underlineStyle: NSUnderlineStyle?
    var underlineColor: UIColor?
    var lineBreakMode: NSLineBreakMode?
    
    // MARK: Initializer
    
    init(
        font: UIFont = .preferredFont(forTextStyle: .body),
        foregroundColor: UIColor? = nil,
        alignment: NSTextAlignment? = .natural,
        lineHeight: Metric? = nil,
        letterSpacing: Metric? = nil,
        paragraphSpacing: CGFloat? = nil,
        underlineStyle: NSUnderlineStyle? = nil,
        underlineColor: UIColor? = nil,
        lineBreakMode: NSLineBreakMode? = nil
    ) {
        self.font = font
        self.foregroundColor = foregroundColor
        self.alignment = alignment
        self.lineHeight = lineHeight
        self.letterSpacing = letterSpacing
        self.paragraphSpacing = paragraphSpacing
        self.underlineStyle = underlineStyle
        self.underlineColor = underlineColor
        self.lineBreakMode = lineBreakMode
    }
}

// MARK: Mappers

extension TextAttributes {
    /// 현재 설정된 값을 기반으로 NSAttributedString용 속성 딕셔너리 생성
    func toDictionary() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        var attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: font
        ]
        
        paragraphSpacing.map    { paragraphStyle.paragraphSpacing = $0 }
        alignment.map           { paragraphStyle.alignment = $0 }
        lineBreakMode.map       { paragraphStyle.lineBreakMode = $0 }
        foregroundColor.map { attributes[.foregroundColor] = $0 }
        underlineStyle.map  { attributes[.underlineStyle] = $0.rawValue }
        underlineColor.map  { attributes[.underlineColor] = $0 }
        
        letterSpacing.map {
            let px = switch $0 {
            case .percent(let pc): font.pointSize * (pc/100)
            case .pixel(let px): px
            }
            
            attributes[.kern] = px
        }
        
        lineHeight.map {
            let px = switch $0 {
            case .percent(let pc): font.pointSize * (pc/100)
            case .pixel(let px): px
            }
            
            paragraphStyle.minimumLineHeight = px
            paragraphStyle.maximumLineHeight = px
            attributes[.baselineOffset] = (px-font.lineHeight) / 2
        }
        
        return attributes
    }
    
    /// 설정된 속성으로 AttributeContainer 생성
    func toContainer() -> AttributeContainer {
        // 딕셔너리 생성 로직을 재사용하여 코드 중복 제거
        AttributeContainer(toDictionary())
    }
    
    /// 설정된 텍스트와 속성으로 NSAttributedString 생성
    func toNSAttributedString(_ text: String) -> NSAttributedString {
        NSAttributedString(string: text, attributes: toDictionary())
    }
    
    /// 설정된 텍스트와 속성으로 Swift의 AttributedString 생성
    func toAttributedString(_ text: String) -> AttributedString {
        AttributedString(text, attributes: toContainer())
    }
}
