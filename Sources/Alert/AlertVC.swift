//
//  AlertVC.swift
//  BoraScaffold
//
//  Created by 신정욱 on 3/19/26.
//

import UIKit

import SnapKit

class AlertVC: UIViewController {
    
    // MARK: Components
    
    /// 실질적인 얼럿 컴포넌트
    /// - 버튼을 추가할 때는 여기에 추가
    let mainVStack = {
        let sv = UIStackView(.vertical)
        sv.backgroundColor = .systemBackground
        sv.layer.cornerRadius = 14
        sv.clipsToBounds = true
        return sv
    }()
    
    /// 콘텐츠 영역 컴포넌트
    /// - 레이블이나 텍스트 뷰를 추가할 때는 여기에 추가
    let contentVStack = UIStackView(.vertical, spacing: 12, inset: .init(edges: 32))
    
    /// 제목 레이블
    let titleLabel = {
        var attrs = TextAttributes()
        attrs.font = .systemFont(ofSize: 20, weight: .semibold)
        attrs.foregroundColor = .label
        attrs.lineHeight = .percent(120)
        attrs.alignment = .center
        let label = AttributedLabel()
        label.defaultTextAttributes = attrs.toDictionary()
        label.numberOfLines = .zero
        return label
    }()
    
    /// 내용 레이블
    let descriptionLabel = {
        var attrs = TextAttributes()
        attrs.font = .systemFont(ofSize: 16, weight: .regular)
        attrs.foregroundColor = .secondaryLabel
        attrs.lineHeight = .percent(140)
        attrs.alignment = .center
        let label = AttributedLabel()
        label.defaultTextAttributes = attrs.toDictionary()
        label.numberOfLines = .zero
        return label
    }()
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    // MARK: Layout
    
    private func setupLayout() {
        view.addSubview(mainVStack)
        mainVStack.addArrangedSubview(contentVStack)
        contentVStack.addArrangedSubview(titleLabel)
        contentVStack.addArrangedSubview(descriptionLabel)
        
        mainVStack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension AlertVC: UIViewControllerTransitioningDelegate {
    /// 프레젠테이션 컨트롤러 설정
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        AlertPresentationController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
    
    /// 화면이 나타날 때 사용할 애니메이터 설정
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        AlertAnimatedTransitioning(.present)
    }
    
    /// 화면이 사라질 때 사용할 애니메이터 설정
    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        AlertAnimatedTransitioning(.dismiss)
    }
}
