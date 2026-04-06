//
//  ToastHostVC.swift
//  BoraScaffold
//
//  Created by 신정욱 on 4/2/26.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit

final class ToastHostVC: UIViewController {
    
    // MARK: Properties
    
    private let bag = DisposeBag()
    
    // MARK: Components
    
    private let toastView = ToastView()
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupLayout()
        setupBindings()
    }
    
    // MARK: Layout
    
    private func setupLayout() {
        view.addSubview(toastView)
        
        toastView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(28)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
    }
    
    // MARK: Bindings
    
    private func setupBindings() {
        /// 토스트 노출 트리거
        let presentTrigger = ToastBus.shared.rx.presentTrigger
        
        /// 토스트 숨김 트리거
        let dismissTrigger = presentTrigger
            .debounce(.seconds(3), scheduler: MainScheduler.instance)
            .map { _ in }
        
        // 주어진 텍스트로 토스트 노출, 만약 이미 노출 중이면 텍스트만 갱신
        presentTrigger
            .bind(with: self) { owner, message in
                owner.toastView.descriptionLabel.text = message
                
                guard owner.toastView.isHidden else { return }
                owner.toastView.present()
            }
            .disposed(by: bag)
        
        // 일정 시간 경과 후, 자동 닫힘
        dismissTrigger
            .bind { [weak self] in self?.toastView.dismiss() }
            .disposed(by: bag)
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview { ToastHostVC() }
