//
//  RxConfirmAlertVC.swift
//  BoraScaffold
//
//  Created by 신정욱 on 3/19/26.
//

import UIKit

import RxSwift

/// 취소, 확인 버튼이 있는 얼럿
class RxConfirmAlertVC: AlertVC {
    
    // MARK: Properties
    
    let bag = DisposeBag()
    
    // MARK: Components
    
    /// 버튼을 가로 배치하는 스택뷰
    private let buttonHStack = {
        let sv = UIStackView()
        sv.backgroundColor = .separator
        sv.distribution = .fillEqually
        sv.spacing = 1
        return sv
    }()
    
    /// 취소 버튼
    let cancelButton = {
        var attrs = TextAttributes()
        attrs.font = .systemFont(ofSize: 18, weight: .medium)
        attrs.foregroundColor = .secondaryLabel
        attrs.lineHeight = .percent(120)
        let button = AlertButton()
        button.defaultTitleAttributes = attrs.toContainer()
        button.title = "취소"
        return button
    }()
    
    /// 확인 버튼
    let acceptButton = {
        var attrs = TextAttributes()
        attrs.font = .systemFont(ofSize: 18, weight: .semibold)
        attrs.foregroundColor = .label
        attrs.lineHeight = .percent(120)
        let button = AlertButton()
        button.defaultTitleAttributes = attrs.toContainer()
        button.title = "확인"
        return button
    }()
    
    // MARK: Life Cycle
    
    init(acceptOnly: Bool) {
        cancelButton.isHidden = acceptOnly
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    // MARK: Layout
    
    private func setupLayout() {
        mainVStack.addArrangedSubview(UIDivider(height: 1, color: .separator))
        mainVStack.addArrangedSubview(buttonHStack)
        buttonHStack.addArrangedSubview(cancelButton)
        buttonHStack.addArrangedSubview(acceptButton)
    }
}
