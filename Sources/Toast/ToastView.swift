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
    
    private let panGesture = UIPanGestureRecognizer()
    
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
        inset = .init(horizontal: 20, vertical: 12)
        isHidden = true
        spacing = 12
        
        addGestureRecognizer(panGesture)
        layer.cornerRadius = cornerRadius
        
        panGesture.addTarget(self, action: #selector(handlePanGesture(_:)))
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
    
    /// 토스트에 연결된 pan 제스처를 처리
    /// - 아래로 스와이프 dismiss와 드래그 저항 애니메이션을 적용함
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            /// 현재 pan 기준 누적 이동 거리
            let translation = gesture.translation(in: self)
            
            /// 토스트가 따라오는 최대 범위
            /// - 아래로 내릴 때는 자연스럽게 더 많이, 위로 밀 때는 거의 움직이지 않게 제한
            let verticalLimit: CGFloat = translation.y > 0 ? 32 : 4
            
            /// 드래그 거리가 커질수록 실제 이동량 증가폭이 줄어들도록 감쇠를 주는 기준값
            let resistance: CGFloat = 72
            
            /// 손가락 이동량을 그대로 쓰지 않고 비선형 감쇠를 적용해서
            /// 토스트가 살짝 버티는 느낌으로 따라오게 만듦
            let dampedY = translation.y
            / (abs(translation.y) + resistance)
            * verticalLimit
            
            /// x축 이동은 무시하고 y축만 반영해 토스트를 수직으로만 끌어내림
            transform = .init(translationX: 0, y: dampedY)
            
        case .ended, .cancelled, .failed:
            /// 손을 떼는 순간 dismiss 여부를 판단할 때 사용할 속도값
            let velocity = gesture.velocity(in: self)
            
            /// 아래 방향 속도가 충분히 크면 사용자가 닫으려는 의도로 보고 바로 dismiss
            if velocity.y > 300 {
                dismiss(offset: max(transform.ty, 0))
                return
            }
            
            /// dismiss 조건을 넘지 못하면 스프링 애니메이션으로 원래 위치로 복귀
            UIView.animate(
                withDuration: 0.32,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0,
                options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]
            ) { [weak self] in
                self?.transform = .identity
            }
            
        default:
            break
        }
    }
    
    // MARK: Public Method
    
    /// 토스트가 아래에서 위로 올라오며 페이드 인
    func present() {
        // 애니메이션 시작 전 상태 설정
        transform = .init(translationX: 0, y: frame.height/3)
        isUserInteractionEnabled = false
        isHidden = false
        alpha = 0
        
        UIView.animate(
            withDuration: 0.32,
            delay: 0,
            options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]
        ) { [weak self] in
            self?.transform = .identity
            self?.alpha = 1
            
        } completion: { [weak self] _ in
            self?.isUserInteractionEnabled = true
        }
    }
    
    /// 토스트가 아래로 내리며 페이드 아웃
    func dismiss(offset: CGFloat = .zero) {
        isUserInteractionEnabled = false
        
        UIView.animate(
            withDuration: 0.32,
            delay: 0,
            options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction]
        ) { [weak self] in
            guard let self else { return }
            transform = .init(translationX: 0, y: frame.height/3 + offset)
            alpha = 0
            
        } completion: { [weak self] _ in
            self?.isHidden = true
        }
    }
}

