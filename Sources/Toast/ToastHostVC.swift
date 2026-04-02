//
//  ToastHostVC.swift
//  BoraScaffold
//
//  Created by 신정욱 on 4/2/26.
//

import UIKit

import SnapKit

final class ToastHostVC: UIViewController {
    
    // MARK: Properties
    
    
    // MARK: Components
    
    private let toastView = ToastView()
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        toastView.descriptionLabel.text = "계좌는 최대 3개까지만 등록 가능합니다.\n일단 개행 쪽도 테스트 해봐야 해용.\n그럼 3줄 째는 어떨까요?"
        
//        Task { @MainActor in
//            try? await Task.sleep(for: .seconds(1))
//            toastView.updateHidden(true)
//            try? await Task.sleep(for: .seconds(1))
//            toastView.updateHidden(false)
//            try? await Task.sleep(for: .seconds(1))
//            toastView.updateHidden(true)
//            try? await Task.sleep(for: .seconds(1))
//            toastView.updateHidden(false)
//            try? await Task.sleep(for: .seconds(1))
//            toastView.updateHidden(true)
//        }
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
    
    private func setupBindings() {}
}

// MARK: - Preview

import SwiftUI
@available(iOS 17.0, *)
#Preview { ToastHostVC() }
