//
//  ToastView.swift
//  BoraScaffold
//
//  Created by 신정욱 on 4/2/26.
//

import UIKit

final class ToastView: UIStackView {
    
    // MARK: Properties
    
    private let cornerRadius: CGFloat = 14
    
    // MARK: Components
    
    let panGesture = UIPanGestureRecognizer()
    
    /// 그림자 레이어 1
    private let firstShadowLayer = {
        let layer = CAShapeLayer()
        layer.shadowOffset = .init(width: 0, height: 4)
        layer.shadowRadius = 3
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    /// 그림자 레이어 2
    private let secondShadowLayer = {
        let layer = CAShapeLayer()
        layer.shadowOffset = .init(width: 0, height: 10)
        layer.shadowRadius = 7.5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    /// 백그라운드 레이어
    private let backgroundLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor(hex: 0x1E2939).cgColor
        return layer
    }()
    
    /// 느낌표 이미지 뷰
    private let exclamationImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "exclamationmark.circle")
        iv.contentMode = .center
        return iv
    }()
    
    /// 내용 레이블
    let descriptionLabel = {
        var attrs = TextAttributes()
        attrs.font = .systemFont(ofSize: 14)
        attrs.letterSpacing = .pixel(-0.15)
        attrs.lineHeight = .pixel(20)
        attrs.foregroundColor = .white
        let label = AttributedLabel()
        label.defaultTextAttributes = attrs.toDictionary()
        label.numberOfLines = .zero
        return label
    }()
    
    // MARK: Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaults()
        setupLayout()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayerPaths()
    }
    
    // MARK: Defaults
    
    private func setupDefaults() {
        addGestureRecognizer(panGesture)
        // 토스트는 별도 swipe recognizer를 두지 않고,
        // 하나의 pan gesture 안에서 "미세한 끌림"과 "아래 플릭 dismiss"를 함께 처리한다.
        // 드래그 중에는 토스트가 손가락 방향으로 조금만 따라오고,
        // 제스처 종료 시점의 y축 속도가 충분히 크면 아래로 쓸어내린 것으로 간주해 닫는다.
        panGesture.addTarget(self, action: #selector(handlePanGesture(_:)))
        
        layer.cornerRadius = cornerRadius
        
        inset = .init(horizontal: 20, vertical: 12)
        spacing = 12
    }
    
    // MARK: Layout
    
    private func setupLayout() {
        layer.addSublayer(firstShadowLayer)
        layer.addSublayer(secondShadowLayer)
        layer.addSublayer(backgroundLayer)
        addArrangedSubview(exclamationImageView)
        addArrangedSubview(descriptionLabel)
        
        exclamationImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        exclamationImageView.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    // MARK: Private Helpers
    
    /// 각 레이어 사이즈 갱신
    private func updateLayerPaths() {
        let path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath
        
        firstShadowLayer.frame = bounds
        firstShadowLayer.shadowPath = path
        
        secondShadowLayer.frame = bounds
        secondShadowLayer.shadowPath = path
        
        backgroundLayer.frame = bounds
        backgroundLayer.path = path
    }
    
    /// 토스트의 표시/숨김 상태를 애니메이션과 함께 갱신
    func updateHidden(_ hidden: Bool, offset: CGFloat = .zero) {
        // 사용자 인터렉션 허용 여부 할당
        isUserInteractionEnabled = !hidden
        
        UIView.animate(
            withDuration: 0.32,
            delay: 0,
            options: [
                .curveEaseInOut,
                .beginFromCurrentState,
                .allowUserInteraction
            ]
        ) { [weak self] in
            guard let self else { return }
            // 아래로 살짝 밀어내며 fade out, 다시 나타날 땐 원위치로 복귀한다.
            transform = hidden
            ? .init(translationX: 0, y: frame.height/3 + offset)
            : .identity
            alpha = hidden ? 0 : 1
        }
    }
    
    @objc
    private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        /// 드래그 이동량
        let translation = gesture.translation(in: self)
        /// 드래그 가속도
        let velocity = gesture.velocity(in: self)
        
        switch gesture.state {
        case .began, .changed:
            guard !isHidden else { return }
            
            /// 방향에 따라 허용할 최대 y축 이동량
            /// - 토스트가 아래로는 더 많이, 위로는 아주 조금만 따라오도록 제한
            let verticalLimit: CGFloat = translation.y > 0 ? 32 : 4
            
            /// 드래그할수록 점점 덜 따라오게 만드는 저항값
            let resistance: CGFloat = 72
            
            /// 감쇠가 적용된 최종 y축 이동값
            let dampedY = translation.y
            / (abs(translation.y) + resistance)
            * verticalLimit
            
            transform = .init(translationX: 0, y: dampedY)
            
        case .ended, .cancelled, .failed:
            if velocity.y > 500 {
                updateHidden(true, offset: max(transform.ty, 0))
                return
            }
            
            UIView.animate(
                withDuration: 0.32,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0,
                options: [
                    .curveEaseOut,
                    .beginFromCurrentState,
                    .allowUserInteraction
                ]
            ) { [weak self] in
                self?.transform = .identity
            }
            
        default:
            break
        }
    }
}
